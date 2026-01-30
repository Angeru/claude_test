module Admin
  class WarbandSkillsController < BaseController
    before_action :set_warband_member
    before_action :set_skill, only: [:show, :edit, :update, :destroy]

    def index
      @skills = @warband_member.warband_skills.by_name
    end

    def show
    end

    def new
      @skill = @warband_member.warband_skills.build
    end

    def create
      @skill = @warband_member.warband_skills.build(skill_params)

      if @skill.save
        redirect_to admin_warband_warband_member_warband_skills_path(@warband_member.warband, @warband_member),
                    notice: "Skill añadida exitosamente"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @skill.update(skill_params)
        redirect_to admin_warband_warband_member_warband_skills_path(@warband_member.warband, @warband_member),
                    notice: "Skill actualizada exitosamente"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @skill.destroy
      redirect_to admin_warband_warband_member_warband_skills_path(@warband_member.warband, @warband_member),
                  notice: "Skill eliminada exitosamente"
    end

    private

    def set_warband_member
      @warband_member = WarbandMember.find(params[:warband_member_id])
    end

    def set_skill
      @skill = @warband_member.warband_skills.find(params[:id])
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
end
