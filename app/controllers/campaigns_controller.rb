class CampaignsController < ApplicationController
  before_action :require_login
  before_action :set_campaign, only: [:show, :subscribe, :unsubscribe, :manage_warbands]

  def index
    @campaigns = Campaign.active.includes(:user, :subscribers).order(created_at: :desc)
    @subscribed_campaign_ids = current_user.campaign_ids
  end

  def show
    @is_subscribed = current_user.campaigns.include?(@campaign)
    @available_warbands = current_user.warbands.available unless @is_subscribed
  end

  def my_campaigns
    @campaigns = current_user.campaigns.includes(:user).order(created_at: :desc)
  end

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = Campaign.new(campaign_params)
    @campaign.user = current_user
    @campaign.status = "activa"

    if @campaign.save
      # Auto-subscribe creator to their own campaign
      current_user.campaigns << @campaign unless current_user.campaigns.include?(@campaign)

      redirect_to campaign_path(@campaign), notice: "Campaña creada correctamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def subscribe
    if current_user.campaigns.include?(@campaign)
      redirect_to campaign_path(@campaign), alert: "Ya estás suscrito a esta campaña"
      return
    end

    warband = current_user.warbands.available.find_by(id: params[:warband_id])

    if warband.nil?
      redirect_to campaign_path(@campaign), alert: "Debes seleccionar una warband disponible para suscribirte"
      return
    end

    subscription = Subscription.new(user: current_user, campaign: @campaign, warband: warband)

    if subscription.save
      redirect_to campaign_path(@campaign), notice: "Te has suscrito correctamente a la campaña con la warband #{warband.name}"
    else
      redirect_to campaign_path(@campaign), alert: subscription.errors.full_messages.join(", ")
    end
  end

  def unsubscribe
    if campaign_owner?(@campaign)
      redirect_to campaign_path(@campaign), alert: "No puedes desuscribirte de tu propia campaña"
      return
    end

    subscription = current_user.subscriptions.find_by(campaign: @campaign)

    if subscription
      subscription.destroy
      redirect_to my_campaigns_campaigns_path, notice: "Te has desuscrito correctamente de la campaña"
    else
      redirect_to my_campaigns_campaigns_path, alert: "No estás suscrito a esta campaña"
    end
  end

  def manage_warbands
    unless campaign_owner?(@campaign)
      redirect_to campaigns_path, alert: "No tienes permiso para gestionar esta campaña"
      return
    end

    @warbands = @campaign.warbands.includes(:user, :warband_members).order(:name)
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:name, :description, :start_date, :end_date)
  end
end
