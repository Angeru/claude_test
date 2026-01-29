class MatchupsController < ApplicationController
  before_action :require_login
  before_action :set_campaign_round
  before_action :authorize_campaign_viewer!, only: [:index, :show]
  before_action :authorize_campaign_manager!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_matchup, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to campaign_campaign_round_path(@campaign_round.campaign, @campaign_round)
  end

  def show
  end

  def new
    @matchup = @campaign_round.matchups.build
    @available_warbands = @campaign_round.campaign.warbands
  end

  def create
    @matchup = @campaign_round.matchups.build(matchup_params)
    @matchup.result = 'pending' if @matchup.result.blank?

    if @matchup.save
      redirect_to campaign_campaign_round_path(@campaign_round.campaign, @campaign_round),
                  notice: "Emparejamiento creado exitosamente"
    else
      @available_warbands = @campaign_round.campaign.warbands
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_warbands = @campaign_round.campaign.warbands
  end

  def update
    if @matchup.update(matchup_params)
      # Auto-calcular ganador si se proporcionan puntuaciones
      if @matchup.warband_1_score.present? && @matchup.warband_2_score.present? && @matchup.result == 'pending'
        @matchup.auto_calculate_result!
      end

      redirect_to campaign_campaign_round_path(@campaign_round.campaign, @campaign_round),
                  notice: "Resultado actualizado exitosamente"
    else
      @available_warbands = @campaign_round.campaign.warbands
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @matchup.destroy
    redirect_to campaign_campaign_round_path(@campaign_round.campaign, @campaign_round),
                notice: "Emparejamiento eliminado exitosamente"
  end

  private

  def set_campaign_round
    @campaign_round = CampaignRound.find(params[:campaign_round_id])
  end

  def set_matchup
    @matchup = @campaign_round.matchups.find(params[:id])
  end

  # Allows subscribers, owners, and admins to view
  def authorize_campaign_viewer!
    campaign = @campaign_round.campaign
    unless can_view_campaign?(campaign)
      redirect_to campaigns_path,
                  alert: "No tienes permiso para ver esta campaña"
    end
  end

  # Allows only owners and admins to manage
  def authorize_campaign_manager!
    campaign = @campaign_round.campaign
    unless can_manage_campaign?(campaign)
      redirect_to campaigns_path,
                  alert: "No tienes permiso para gestionar esta campaña"
    end
  end

  def matchup_params
    params.require(:matchup).permit(
      :warband_1_id, :warband_2_id, :result, :winner_id,
      :warband_1_score, :warband_2_score,
      :warband_1_casualties, :warband_2_casualties,
      :warband_1_primary_objective, :warband_2_primary_objective,
      :warband_1_secondary_objective, :warband_2_secondary_objective,
      :notes
    )
  end
end
