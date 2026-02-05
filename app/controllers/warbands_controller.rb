class WarbandsController < ApplicationController
  before_action :require_login
  before_action :set_warband, only: [:show, :edit, :update, :destroy, :remove_from_campaign]
  before_action :authorize_warband_access!, only: [:edit, :update, :destroy, :remove_from_campaign]

  def index
    @warbands = current_user.warbands.includes(:campaign).recent
    @available_campaigns = current_user.campaigns.active
  end

  def show
    # Verificar permisos de visibilidad
    unless can_view_warband?(@warband)
      redirect_to warbands_path, alert: "No tienes permiso para ver esta warband"
      return
    end

    @active_matchups = Matchup.includes(:campaign_round => :campaign, :warband_1 => :user, :warband_2 => :user, :battle_rosters => [])
                              .where('warband_1_id = :wid OR warband_2_id = :wid', wid: @warband.id)
  end

  def new
    @warband = current_user.warbands.build
  end

  def create
    @warband = current_user.warbands.build(warband_params)

    if @warband.save
      redirect_to warbands_path, notice: "Warband creada exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @warband.update(warband_params)
      redirect_to warbands_path, notice: "Warband actualizada exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless @warband.user == current_user
      redirect_to warbands_path, alert: "Solo el propietario puede eliminar la warband"
      return
    end

    @warband.destroy
    redirect_to warbands_path, notice: "Warband eliminada exitosamente"
  end

  def remove_from_campaign
    @warband.remove_from_campaign
    redirect_to warbands_path, notice: "Warband removida de la campaña"
  end

  private

  def set_warband
    @warband = Warband.find(params[:id])
  end

  def authorize_warband_access!
    unless can_manage_warband?(@warband)
      redirect_to warbands_path, alert: "No tienes permiso para modificar esta warband"
    end
  end

  def can_view_warband?(warband)
    # El dueño siempre puede ver
    return true if warband.user == current_user

    # Usuarios en la misma campaña pueden ver
    if warband.campaign_id.present?
      shared_campaigns = current_user.campaigns.where(id: warband.campaign_id)
      return true if shared_campaigns.exists?
    end

    false
  end

  def warband_params
    params.require(:warband).permit(:name, :campaign_id, :gold, :influence)
  end
end
