module Admin
  class WarbandMembersController < BaseController
    before_action :set_warband
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
        redirect_to admin_warband_warband_members_path(@warband),
                    notice: "Miembro añadido correctamente"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @member.update(member_params)
        redirect_to admin_warband_warband_members_path(@warband),
                    notice: "Miembro actualizado correctamente"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @member.destroy
      redirect_to admin_warband_warband_members_path(@warband),
                  notice: "Miembro eliminado correctamente"
    end

    private

    def set_warband
      @warband = Warband.find(params[:warband_id])
    end

    def set_member
      @member = @warband.warband_members.find(params[:id])
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
end
