class SkillsController < ApplicationController
  before_action :require_login
  before_action :set_skill, only: [:show, :edit, :update, :destroy]

  def index
    @skills = Skill.by_name
  end

  def show
  end

  def new
    @skill = Skill.new
  end

  def create
    @skill = Skill.new(skill_params)

    if @skill.save
      redirect_to skills_path, notice: "Skill añadida al catálogo exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @skill.update(skill_params)
      redirect_to skills_path, notice: "Skill actualizada exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @skill.destroy
    redirect_to skills_path, notice: "Skill eliminada del catálogo"
  end

  private

  def set_skill
    @skill = Skill.find(params[:id])
  end

  def skill_params
    params.require(:skill).permit(
      :name, :description, :skill_type, :cost,
      :movimiento_modifier, :lucha_modifier, :proyectiles_modifier,
      :fuerza_modifier, :defensa_modifier, :ataques_modifier,
      :heridas_modifier, :coraje_modifier, :inteligencia_modifier,
      :might_modifier, :will_modifier, :fate_modifier
    )
  end
end
