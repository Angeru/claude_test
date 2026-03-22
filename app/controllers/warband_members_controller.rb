class WarbandMembersController < ApplicationController
  before_action :require_login
  before_action :set_warband
  before_action :authorize_view_access!, only: [:index, :show]
  before_action :authorize_manage_access!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  def index
    @members = @warband.warband_members.by_name
    @heroes = @warband.warband_members.heroes.by_rank_then_name
    @warriors = @members.warriors
  end

  def show
  end

  def new
    @member = @warband.warband_members.build
    @profiles = current_user.member_profiles.by_name

    if params[:profile_id].present?
      profile = current_user.member_profiles.find_by(id: params[:profile_id])
      profile&.apply_to_member(@member)
    end
  end

  def create
    @member = @warband.warband_members.build(member_params)
    @profiles = current_user.member_profiles.by_name

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

  def authorize_view_access!
    unless can_view_warband?(@warband)
      redirect_to warbands_path,
                  alert: "No tienes permiso para ver esta warband"
    end
  end

  def authorize_manage_access!
    unless can_manage_warband?(@warband)
      redirect_to warbands_path,
                  alert: "No tienes permiso para modificar esta warband"
    end
  end

  def member_params
    permitted = [ :name, :member_type, :rank, :path, :ranking,
                  :movimiento, :lucha, :proyectiles, :fuerza, :defensa,
                  :ataques, :heridas, :coraje, :inteligencia,
                  :might, :will, :fate, :experience ]

    # When the warband is in a campaign, stats cannot be directly modified
    if @warband.in_campaign?
      permitted -= WarbandMember::STAT_FIELDS.map(&:to_sym)
    end

    p = params.require(:warband_member).permit(*permitted)
    p[:rank] = nil if p[:rank].blank?
    p[:path] = nil if p[:path].blank?
    p
  end
end
