class MemberProfilesController < ApplicationController
  before_action :require_login
  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  def index
    @profiles = current_user.member_profiles.by_name
  end

  def show
  end

  def new
    @profile = current_user.member_profiles.build
  end

  def create
    @profile = current_user.member_profiles.build(profile_params)

    if @profile.save
      redirect_to member_profiles_path, notice: "Perfil creado exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to member_profiles_path, notice: "Perfil actualizado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.destroy
    redirect_to member_profiles_path, notice: "Perfil eliminado exitosamente"
  end

  private

  def set_profile
    @profile = current_user.member_profiles.find(params[:id])
  end

  def profile_params
    params.require(:member_profile).permit(
      :name, :member_type, :rank, :experience, :ranking,
      :movimiento, :lucha, :proyectiles, :fuerza, :defensa,
      :ataques, :heridas, :coraje, :inteligencia,
      :might, :will, :fate
    ).tap { |p| p[:rank] = nil if p[:rank].blank? }
  end
end
