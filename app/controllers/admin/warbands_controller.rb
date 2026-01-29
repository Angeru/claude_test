module Admin
  class WarbandsController < BaseController
    before_action :set_warband, only: [:show, :edit, :update, :destroy, :remove_from_campaign]

    def index
      @warbands = Warband.includes(:user, :campaign).order(created_at: :desc)
    end

    def show
    end

    def new
      @warband = Warband.new
      @users = User.where(role: "user").order(:name)
      @campaigns = Campaign.order(:name)
    end

    def create
      @warband = Warband.new(warband_params)

      if @warband.save
        redirect_to admin_warbands_path, notice: "Warband creada correctamente"
      else
        @users = User.where(role: "user").order(:name)
        @campaigns = Campaign.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @users = User.where(role: "user").order(:name)
      @campaigns = Campaign.order(:name)
    end

    def update
      if @warband.update(warband_params)
        redirect_to admin_warbands_path, notice: "Warband actualizada correctamente"
      else
        @users = User.where(role: "user").order(:name)
        @campaigns = Campaign.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @warband.destroy
      redirect_to admin_warbands_path, notice: "Warband eliminada correctamente"
    end

    def remove_from_campaign
      @warband.remove_from_campaign
      redirect_to admin_warband_path(@warband), notice: "Warband removida de la campaña"
    end

    private

    def set_warband
      @warband = Warband.find(params[:id])
    end

    def warband_params
      params.require(:warband).permit(:name, :user_id, :campaign_id, :gold, :influence)
    end
  end
end
