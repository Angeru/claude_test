class WarbandSkillsController < ApplicationController
  before_action :require_login
  before_action :set_warband_member
  before_action :authorize_warband_view!, only: [:index]
  before_action :authorize_warband_access!, only: [:new, :create, :edit, :update, :destroy, :save_as_profile]
  before_action :set_skill, only: [:show, :edit, :update, :destroy, :save_as_profile]

  def index
    @skills = @warband_member.warband_skills.by_name
  end

  def show
  end

  def new
    @skill = @warband_member.warband_skills.build
    if params[:from_skill_id].present?
      catalog_skill = Skill.find_by(id: params[:from_skill_id])
      if catalog_skill
        @skill.assign_attributes(
          name: catalog_skill.name, description: catalog_skill.description,
          skill_type: catalog_skill.skill_type, cost: catalog_skill.cost,
          movimiento_modifier: catalog_skill.movimiento_modifier,
          lucha_modifier: catalog_skill.lucha_modifier,
          proyectiles_modifier: catalog_skill.proyectiles_modifier,
          fuerza_modifier: catalog_skill.fuerza_modifier,
          defensa_modifier: catalog_skill.defensa_modifier,
          ataques_modifier: catalog_skill.ataques_modifier,
          heridas_modifier: catalog_skill.heridas_modifier,
          coraje_modifier: catalog_skill.coraje_modifier,
          inteligencia_modifier: catalog_skill.inteligencia_modifier,
          might_modifier: catalog_skill.might_modifier,
          will_modifier: catalog_skill.will_modifier,
          fate_modifier: catalog_skill.fate_modifier
        )
      end
    end
    @catalog_skills = Skill.by_name
  end

  def create
    @skill = @warband_member.warband_skills.build(skill_params)

    if @skill.save
      redirect_to warband_warband_member_warband_skills_path(@warband_member.warband, @warband_member),
                  notice: "Skill añadida exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @skill.update(skill_params)
      redirect_to warband_warband_member_warband_skills_path(@warband_member.warband, @warband_member),
                  notice: "Skill actualizada exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @skill.destroy
    redirect_to warband_warband_member_warband_skills_path(@warband_member.warband, @warband_member),
                notice: "Skill eliminada exitosamente"
  end

  def save_as_profile
    profile = Skill.new(
      name: @skill.name,
      description: @skill.description,
      skill_type: @skill.skill_type,
      cost: @skill.cost,
      movimiento_modifier: @skill.movimiento_modifier,
      lucha_modifier: @skill.lucha_modifier,
      proyectiles_modifier: @skill.proyectiles_modifier,
      fuerza_modifier: @skill.fuerza_modifier,
      defensa_modifier: @skill.defensa_modifier,
      ataques_modifier: @skill.ataques_modifier,
      heridas_modifier: @skill.heridas_modifier,
      coraje_modifier: @skill.coraje_modifier,
      inteligencia_modifier: @skill.inteligencia_modifier,
      might_modifier: @skill.might_modifier,
      will_modifier: @skill.will_modifier,
      fate_modifier: @skill.fate_modifier
    )

    if profile.save
      redirect_to edit_warband_warband_member_warband_skill_path(@warband_member.warband, @warband_member, @skill),
                  notice: "\"#{profile.name}\" guardado como perfil en el catálogo"
    else
      redirect_to edit_warband_warband_member_warband_skill_path(@warband_member.warband, @warband_member, @skill),
                  alert: "Error al guardar el perfil: #{profile.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_warband_member
    @warband_member = WarbandMember.find(params[:warband_member_id])
  end

  def set_skill
    @skill = @warband_member.warband_skills.find(params[:id])
  end

  def authorize_warband_view!
    unless can_view_warband?(@warband_member.warband)
      redirect_to warbands_path,
                  alert: "No tienes permiso para ver estas skills"
    end
  end

  def authorize_warband_access!
    unless can_manage_warband?(@warband_member.warband)
      redirect_to warbands_path,
                  alert: "No tienes permiso para modificar estas skills"
    end
  end

  def skill_params
    params.require(:warband_skill).permit(
      :name, :description, :skill_type, :cost,
      :movimiento_modifier, :lucha_modifier, :proyectiles_modifier,
      :fuerza_modifier, :defensa_modifier, :ataques_modifier,
      :heridas_modifier, :coraje_modifier, :inteligencia_modifier,
      :might_modifier, :will_modifier, :fate_modifier
    )
  end
end
