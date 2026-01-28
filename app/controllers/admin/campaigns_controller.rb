module Admin
  class CampaignsController < BaseController
    before_action :set_campaign, only: [:show, :edit, :update, :destroy, :manage_subscriptions, :update_subscriptions]

    def index
      @campaigns = Campaign.includes(:user).order(created_at: :desc)
    end

    def show
      @subscribers = @campaign.subscribers.order(created_at: :desc)
    end

    def new
      @campaign = Campaign.new
    end

    def create
      @campaign = Campaign.new(campaign_params)
      @campaign.user = current_user unless campaign_params[:user_id].present?

      if @campaign.save
        redirect_to admin_campaigns_path, notice: "Campaña creada correctamente"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @campaign.update(campaign_params)
        redirect_to admin_campaigns_path, notice: "Campaña actualizada correctamente"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @campaign.destroy
      redirect_to admin_campaigns_path, notice: "Campaña eliminada correctamente"
    end

    def manage_subscriptions
      @all_users = User.where(role: "user").order(:name)
      @subscriber_ids = @campaign.subscriber_ids
    end

    def update_subscriptions
      subscriber_ids = params[:campaign][:subscriber_ids].reject(&:blank?)
      @campaign.subscriber_ids = subscriber_ids
      redirect_to admin_campaign_path(@campaign), notice: "Suscripciones actualizadas correctamente"
    end

    private

    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    def campaign_params
      params.require(:campaign).permit(:name, :description, :status, :start_date, :end_date, :user_id)
    end
  end
end
