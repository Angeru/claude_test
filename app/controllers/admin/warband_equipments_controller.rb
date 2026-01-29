module Admin
  class WarbandEquipmentsController < AdminController
    before_action :set_warband_member
    before_action :set_equipment, only: [:show, :edit, :update, :destroy]

    def index
      @equipments = @warband_member.warband_equipments.by_name
    end

    def show
    end

    def new
      @equipment = @warband_member.warband_equipments.build
    end

    def create
      @equipment = @warband_member.warband_equipments.build(equipment_params)

      if @equipment.save
        redirect_to admin_warband_warband_member_warband_equipments_path(@warband_member.warband, @warband_member),
                    notice: "Equipo añadido exitosamente"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @equipment.update(equipment_params)
        redirect_to admin_warband_warband_member_warband_equipments_path(@warband_member.warband, @warband_member),
                    notice: "Equipo actualizado exitosamente"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @equipment.destroy
      redirect_to admin_warband_warband_member_warband_equipments_path(@warband_member.warband, @warband_member),
                  notice: "Equipo eliminado exitosamente"
    end

    private

    def set_warband_member
      @warband_member = WarbandMember.find(params[:warband_member_id])
    end

    def set_equipment
      @equipment = @warband_member.warband_equipments.find(params[:id])
    end

    def equipment_params
      params.require(:warband_equipment).permit(
        :name, :description, :equipment_type, :cost,
        :movimiento_modifier, :lucha_modifier, :proyectiles_modifier,
        :fuerza_modifier, :defensa_modifier, :ataques_modifier,
        :heridas_modifier, :coraje_modifier, :inteligencia_modifier,
        :might_modifier, :will_modifier, :fate_modifier
      )
    end
  end
end
