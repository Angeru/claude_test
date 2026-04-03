class BattleRosterUnitsController < ApplicationController
  before_action :require_login
  before_action :set_context
  before_action :authorize_battle_action!

  def wound
    @unit.take_wound!
    respond_with_streams
  end

  def heal
    @unit.restore_wound!
    respond_with_streams
  end

  def spend
    @unit.spend!(params[:attribute])
    respond_with_streams
  end

  def restore
    @unit.restore!(params[:attribute])
    respond_with_streams
  end

  def toggle_tick
    @unit.toggle_tick!(params[:tick])
    respond_with_streams
  rescue ArgumentError
    respond_to do |format|
      format.turbo_stream { head :unprocessable_entity }
      format.html { redirect_to_battle alert: "Tick inválido" }
    end
  end

  def toggle_mvp
    @unit.set_mvp!(!@unit.mvp)
    respond_with_streams
  end

  def kill
    @unit.kill!
    respond_with_streams
  end

  def unkill
    @unit.unkill!
    respond_with_streams
  end

  def flee
    @unit.flee!
    respond_with_streams
  end

  private

  def set_context
    @matchup = Matchup.find(params[:matchup_id])
    @battle_roster = @matchup.battle_rosters.find(params[:battle_roster_id])
    @unit = @battle_roster.battle_roster_units.find(params[:id])
    @round = @matchup.campaign_round
    @campaign = @round.campaign
  end

  def authorize_battle_action!
    user_warband_ids = current_user.warbands.pluck(:id)
    is_owner = user_warband_ids.include?(@battle_roster.warband_id)
    is_manager = can_manage_campaign?(@campaign)

    unless is_owner || is_manager
      redirect_to_battle alert: "No tienes permiso para modificar estas unidades"
    end
  end

  def respond_with_streams
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("battle_roster_unit_#{@unit.id}",
            partial: 'battle_rosters/unit_card', locals: { unit: @unit }),
          turbo_stream.replace("battle_stats_#{@battle_roster.id}",
            partial: 'battle_rosters/battle_stats', locals: { battle_roster: @battle_roster }),
          turbo_stream.replace("banda_rota_#{@battle_roster.id}",
            partial: 'battle_rosters/banda_rota', locals: { battle_roster: @battle_roster })
        ]
      end
      format.html { redirect_to_battle }
    end
  end

  def redirect_to_battle(**options)
    redirect_to campaign_campaign_round_matchup_battle_roster_path(
      @campaign, @round, @matchup, @battle_roster
    ), **options
  end
end
