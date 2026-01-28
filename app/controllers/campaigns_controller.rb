class CampaignsController < ApplicationController
  before_action :require_login
  before_action :set_campaign, only: [:show, :subscribe, :unsubscribe]

  def index
    @campaigns = Campaign.active.includes(:user, :subscribers).order(created_at: :desc)
    @subscribed_campaign_ids = current_user.campaign_ids
  end

  def show
    @is_subscribed = current_user.campaigns.include?(@campaign)
  end

  def my_campaigns
    @campaigns = current_user.campaigns.includes(:user).order(created_at: :desc)
  end

  def subscribe
    if current_user.campaigns.include?(@campaign)
      redirect_to campaign_path(@campaign), alert: "Ya estás suscrito a esta campaña"
    else
      current_user.campaigns << @campaign
      redirect_to campaign_path(@campaign), notice: "Te has suscrito correctamente a la campaña"
    end
  end

  def unsubscribe
    if current_user.campaigns.include?(@campaign)
      current_user.campaigns.delete(@campaign)
      redirect_to my_campaigns_campaigns_path, notice: "Te has desuscrito correctamente de la campaña"
    else
      redirect_to my_campaigns_campaigns_path, alert: "No estás suscrito a esta campaña"
    end
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end
end
