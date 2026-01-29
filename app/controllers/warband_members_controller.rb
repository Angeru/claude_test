class WarbandMembersController < ApplicationController
  before_action :require_login
  before_action :set_warband
  before_action :authorize_warband_access!
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  def index
    @members = @warband.warband_members.by_name
    @heroes = @members.heroes
    @warriors = @members.warriors
  end

  def show
  end

  def new
    @member = @warband.warband_members.build
  end

  def create
    @member = @warband.warband_members.build(member_params)

    if @member.save
      redirect_to warband_warband_members_path(@warband),
                  notice: "Miembro añadido exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @member.update(member_params)
      redirect_to warband_warband_members_path(@warband),
                  notice: "Miembro actualizado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member.destroy
    redirect_to warband_warband_members_path(@warband),
                notice: "Miembro eliminado exitosamente"
  end

  private

  def set_warband
    @warband = Warband.find(params[:warband_id])
  end

  def set_member
    @member = @warband.warband_members.find(params[:id])
  end

  def authorize_warband_access!
    unless can_manage_warband?(@warband)
      redirect_to warbands_path,
                  alert: "No tienes permiso para modificar esta warband"
    end
  end

  def member_params
    params.require(:warband_member).permit(
      :name, :member_type,
      :movimiento, :lucha, :proyectiles, :fuerza, :defensa,
      :ataques, :heridas, :coraje, :inteligencia,
      :might, :will, :fate, :experience
    )
  end
end
