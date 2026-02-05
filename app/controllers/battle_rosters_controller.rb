class BattleRostersController < ApplicationController
  before_action :require_login
  before_action :set_matchup
  before_action :set_battle_roster, only: [:show, :destroy, :toggle]
  before_action :authorize_participant!

  def show
    @campaign = @matchup.campaign_round.campaign
    @round = @matchup.campaign_round
    @units = @battle_roster.battle_roster_units
                           .includes(warband_member: [:warband_equipments, :warband_skills])
                           .order('warband_members.member_type DESC, warband_members.name ASC')
  end

  def create
    warband = find_user_warband
    unless warband
      redirect_to campaign_campaign_round_path(@matchup.campaign_round.campaign, @matchup.campaign_round),
                  alert: "No tienes una warband en este emparejamiento"
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

  def toggle
    @battle_roster.update(active: !@battle_roster.active)
    redirect_to campaign_campaign_round_matchup_battle_roster_path(
      @matchup.campaign_round.campaign, @matchup.campaign_round, @matchup, @battle_roster
    ), notice: @battle_roster.active? ? "Batalla reactivada" : "Batalla pausada"
  end

  private

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
