class BattleRostersController < ApplicationController
  before_action :require_login
  before_action :set_matchup
  before_action :set_battle_roster, only: [:show, :destroy, :toggle, :finalize, :complete, :injury_rolls, :apply_injuries]
  before_action :authorize_participant!

  def show
    @campaign = @matchup.campaign_round.campaign
    @round = @matchup.campaign_round
    @units = @battle_roster.battle_roster_units
                           .includes(warband_member: [:warband_equipments, :warband_skills])
                           .order('warband_members.member_type DESC, warband_members.name ASC')
    if !@battle_roster.active?
      rosters = @matchup.battle_rosters
                        .includes(battle_roster_units: { warband_member: [] })
                        .index_by(&:warband_id)
      @result_warbands = [@matchup.warband_1, @matchup.warband_2].map do |warband|
        { warband: warband, roster: rosters[warband.id] }
      end
    end
  end

  def create
    warband = find_user_warband
    unless warband
      redirect_to campaign_campaign_round_path(@matchup.campaign_round.campaign, @matchup.campaign_round),
                  alert: "No tienes una warband en este emparejamiento"
      return
    end

    existing = @matchup.battle_rosters.find_by(warband: warband)
    if existing && !existing.active?
      redirect_to campaign_campaign_round_path(@matchup.campaign_round.campaign, @matchup.campaign_round),
                  alert: "Ya has finalizado tu batalla en este emparejamiento"
      return
    end

    @battle_roster = @matchup.battle_rosters.find_or_initialize_by(warband: warband)
    if @battle_roster.new_record?
      if @battle_roster.save
        @battle_roster.populate_units!
        redirect_to campaign_campaign_round_matchup_battle_roster_path(
          @matchup.campaign_round.campaign, @matchup.campaign_round, @matchup, @battle_roster
        ), notice: "Modo batalla activado"
      else
        redirect_to campaign_campaign_round_path(@matchup.campaign_round.campaign, @matchup.campaign_round),
                    alert: "No se pudo activar el modo batalla: #{@battle_roster.errors.full_messages.join(', ')}"
      end
    else
      @battle_roster.populate_units!
      redirect_to campaign_campaign_round_matchup_battle_roster_path(
        @matchup.campaign_round.campaign, @matchup.campaign_round, @matchup, @battle_roster
      ), notice: "Modo batalla ya activo"
    end
  end

  def destroy
    @battle_roster.destroy
    redirect_to campaign_campaign_round_path(@matchup.campaign_round.campaign, @matchup.campaign_round),
                notice: "Modo batalla desactivado"
  end

  def finalize
    @campaign = @matchup.campaign_round.campaign
    @round = @matchup.campaign_round
    @units = @battle_roster.battle_roster_units
                           .includes(:warband_member)
                           .order('warband_members.member_type DESC, warband_members.name ASC')
  end

  def complete
    @campaign = @matchup.campaign_round.campaign
    @round = @matchup.campaign_round

    unit_params = params[:units] || {}
    @battle_roster.battle_roster_units.each do |unit|
      on_obj = unit_params.dig(unit.id.to_s, :on_objective) == "1"
      unit.update!(on_objective: on_obj)
    end

    mvp_unit_id = params[:mvp_unit_id].presence
    @battle_roster.battle_roster_units.update_all(mvp: false)
    if mvp_unit_id
      @battle_roster.battle_roster_units.find(mvp_unit_id).update!(mvp: true)
    end

    result = params[:result]
    if Matchup::RESULTS.include?(result) && result != 'pending' && @matchup.pending?
      winner_id = case result
                  when 'warband_1_win' then @matchup.warband_1_id
                  when 'warband_2_win' then @matchup.warband_2_id
                  end
      @matchup.update!(result: result, winner_id: winner_id)
    end

    @battle_roster.update!(active: false)

    if @matchup.battle_rosters.where(active: true).none?
      @matchup.battle_rosters.each(&:award_experience!)
    end

    influence = 2
    influence += case @matchup.result
                 when "draw"
                   1
                 when "warband_1_win"
                   @matchup.warband_1_id == @battle_roster.warband_id ? 2 : 0
                 when "warband_2_win"
                   @matchup.warband_2_id == @battle_roster.warband_id ? 2 : 0
                 else
                   0
                 end
    @battle_roster.warband.increment!(:influence, influence)

    defeated_members = @battle_roster.battle_roster_units.where(defeated: true)
    if defeated_members.any?
      redirect_to injury_rolls_campaign_campaign_round_matchup_battle_roster_path(@campaign, @round, @matchup, @battle_roster),
                  notice: "Batalla finalizada. Realiza las tiradas de heridas para los guerreros caídos."
    else
      redirect_to campaign_campaign_round_path(@campaign, @round),
                  notice: "Batalla finalizada"
    end
  end

  def injury_rolls
    @campaign = @matchup.campaign_round.campaign
    @round = @matchup.campaign_round
    @defeated_warriors = @battle_roster.battle_roster_units
                                       .joins(:warband_member)
                                       .where(defeated: true, warband_members: { member_type: "warrior" })
                                       .includes(:warband_member)
                                       .order("warband_members.name ASC")
    @defeated_heroes = @battle_roster.battle_roster_units
                                     .joins(:warband_member)
                                     .where(defeated: true, warband_members: { member_type: "hero" })
                                     .includes(warband_member: :warband_skills)
                                     .order("warband_members.name ASC")
  end

  def apply_injuries
    @campaign = @matchup.campaign_round.campaign
    @round = @matchup.campaign_round

    (params[:injuries] || {}).each do |member_id, data|
      roll = data[:roll].to_i
      next unless roll.between?(2, 12)

      member = WarbandMember.find_by(id: member_id)
      next unless member

      if member.warrior?
        apply_warrior_injury(member, roll, data)
      else
        apply_hero_injury(member, roll, data)
      end
    end

    redirect_to campaign_campaign_round_path(@campaign, @round),
                notice: "Tiradas de heridas aplicadas"
  end

  def toggle
    @battle_roster.update(active: !@battle_roster.active)
    redirect_to campaign_campaign_round_matchup_battle_roster_path(
      @matchup.campaign_round.campaign, @matchup.campaign_round, @matchup, @battle_roster
    ), notice: @battle_roster.active? ? "Batalla reactivada" : "Batalla pausada"
  end

  private

  def apply_warrior_injury(member, roll, data)
    case roll
    when 2..3 then member.update_column(:dead, true)
    when 4..5 then member.update_column(:injured, true)
    when 6..11 then nil # recuperación completa
    when 12
      bonus = data[:bonus_xp].to_i.clamp(1, 3)
      member.increment!(:experience, bonus)
    end
  end

  def apply_hero_injury(member, roll, data)
    case roll
    when 2
      member.update_column(:dead, true)
    when 3
      if member.arm_injured?
        member.update_column(:dead, true)
      else
        member.update_column(:arm_injured, true)
      end
    when 4
      if member.leg_injured?
        member.update_column(:dead, true)
      else
        member.update_column(:leg_injured, true)
        member.update_column(:movimiento, [ member.movimiento - 1, 0 ].max)
      end
    when 5
      new_count = member.disgrace_count + 1
      if new_count >= 3
        member.update_column(:dead, true)
      else
        member.update_column(:disgrace_count, new_count)
        skill_name = new_count == 1 ? "Deshonrado" : "Temeroso"
        skill_desc = new_count == 1 ? "No puede proporcionar Stand Fast!" : "Fearful"
        member.warband_skills.create!(name: skill_name, description: skill_desc, skill_type: "special")
      end
    when 6
      member.update_column(:injured, true)
    when 7..10
      apply_recovery(member, data[:recovery_choice])
    when 11
      member.update_column(:fate, member.fate + 1)
    when 12
      influence = data[:bonus_influence].to_i.clamp(1, 6)
      member.warband.increment!(:influence, influence)
      apply_recovery(member, data[:recovery_choice])
    end
  end

  def apply_recovery(member, choice)
    case choice
    when "arm"
      member.update_column(:arm_injured, false)
    when "leg"
      member.update_column(:leg_injured, false)
      member.update_column(:movimiento, member.movimiento + 1)
    when "disgrace"
      new_count = [ member.disgrace_count - 1, 0 ].max
      if new_count < member.disgrace_count
        skill_to_remove = member.warband_skills.find_by(name: "Temeroso") ||
                          member.warband_skills.find_by(name: "Deshonrado")
        skill_to_remove&.destroy
        member.update_column(:disgrace_count, new_count)
      end
    end
  end

  def set_matchup
    @matchup = Matchup.find(params[:matchup_id])
  end

  def set_battle_roster
    @battle_roster = @matchup.battle_rosters.find(params[:id])
  end

  def find_user_warband
    [matchup_warband(@matchup.warband_1_id), matchup_warband(@matchup.warband_2_id)].compact.first
  end

  def matchup_warband(warband_id)
    warband = Warband.find_by(id: warband_id)
    warband if warband&.user == current_user
  end

  def authorize_participant!
    campaign = @matchup.campaign_round.campaign
    user_warband_ids = current_user.warbands.pluck(:id)
    is_participant = [@matchup.warband_1_id, @matchup.warband_2_id].any? { |id| user_warband_ids.include?(id) }
    is_manager = can_manage_campaign?(campaign)

    unless is_participant || is_manager
      redirect_to campaign_campaign_round_path(campaign, @matchup.campaign_round),
                  alert: "No tienes permiso para acceder al modo batalla de este emparejamiento"
    end
  end
end
