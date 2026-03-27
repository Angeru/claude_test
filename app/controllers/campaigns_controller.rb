class CampaignsController < ApplicationController
  before_action :require_login
  before_action :set_campaign, only: [:show, :subscribe, :unsubscribe, :manage_warbands, :standings]

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

  def standings
    unless can_view_campaign?(@campaign)
      redirect_to campaign_path(@campaign), alert: "No tienes permiso para ver esta campaña"
      return
    end

    points = Hash.new { |h, k| h[k] = { wins: 0, draws: 0, losses: 0, played: 0 } }

    @campaign.campaign_rounds.each do |round|
      round.matchups.each do |matchup|
        next if matchup.pending?

        w1 = matchup.warband_1_id
        w2 = matchup.warband_2_id

        case matchup.result
        when "warband_1_win"
          points[w1][:wins]   += 1
          points[w2][:losses] += 1
        when "warband_2_win"
          points[w2][:wins]   += 1
          points[w1][:losses] += 1
        when "draw"
          points[w1][:draws] += 1
          points[w2][:draws] += 1
        end

        points[w1][:played] += 1
        points[w2][:played] += 1
      end
    end

    warbands_by_id = @campaign.warbands.index_by(&:id)

    @standings = points.map do |warband_id, stats|
      warband = warbands_by_id[warband_id]
      next unless warband

      pts = stats[:wins] * 3 + stats[:draws]
      { warband: warband, points: pts, **stats }
    end.compact.sort_by { |s| [-s[:points], -s[:wins], s[:warband].name] }
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
