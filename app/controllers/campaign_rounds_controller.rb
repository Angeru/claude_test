class CampaignRoundsController < ApplicationController
  before_action :require_login
  before_action :set_campaign
  before_action :authorize_campaign_viewer!, only: [:index, :show]
  before_action :authorize_campaign_manager!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_round, only: [:show, :edit, :update, :destroy]

  def index
    @rounds = @campaign.campaign_rounds.ordered
  end

  def show
    @matchups = @round.matchups.includes(:warband_1, :warband_2, :winner)
  end

  def new
    @round = @campaign.campaign_rounds.build
    # Auto-asignar el siguiente número de ronda
    last_round = @campaign.campaign_rounds.maximum(:round_number) || 0
    @round.round_number = last_round + 1
  end

  def create
    @round = @campaign.campaign_rounds.build(round_params)

    if @round.save
      redirect_to campaign_campaign_round_path(@campaign, @round),
                  notice: "Ronda creada exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @round.update(round_params)
      redirect_to campaign_campaign_round_path(@campaign, @round),
                  notice: "Ronda actualizada exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @round.destroy
    redirect_to campaign_campaign_rounds_path(@campaign),
                notice: "Ronda eliminada exitosamente"
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def set_round
    @round = @campaign.campaign_rounds.find(params[:id])
  end

  # Allows subscribers, owners, and admins to view
  def authorize_campaign_viewer!
    unless can_view_campaign?(@campaign)
      redirect_to campaigns_path,
                  alert: "No tienes permiso para ver esta campaña"
    end
  end

  # Allows only owners and admins to manage
  def authorize_campaign_manager!
    unless can_manage_campaign?(@campaign)
      redirect_to campaigns_path,
                  alert: "No tienes permiso para gestionar esta campaña"
    end
  end

  def round_params
    params.require(:campaign_round).permit(:round_number, :played_at, :scenario)
  end
end
