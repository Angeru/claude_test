class BattleRosterUnitsController < ApplicationController
  before_action :require_login
  before_action :set_context
  before_action :authorize_battle_action!

  def wound
    @unit.take_wound!
    redirect_to campaign_campaign_round_matchup_battle_roster_path(
      @campaign, @round, @matchup, @battle_roster
    )
  end

  def heal
    @unit.restore_wound!
    redirect_to campaign_campaign_round_matchup_battle_roster_path(
      @campaign, @round, @matchup, @battle_roster
    )
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
      redirect_to campaign_campaign_round_matchup_battle_roster_path(
        @campaign, @round, @matchup, @battle_roster
      ), alert: "No tienes permiso para modificar estas unidades"
    end
  end
end
