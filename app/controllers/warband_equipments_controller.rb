class WarbandEquipmentsController < ApplicationController
  before_action :require_login
  before_action :set_warband_member
  before_action :authorize_warband_access!
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]

  def index
    @equipments = @warband_member.warband_equipments.by_name
  end

  def show
  end

  def new
    @equipment = @warband_member.warband_equipments.build
    if params[:from_equipment_id].present?
      catalog_equipment = Equipment.find_by(id: params[:from_equipment_id])
      if catalog_equipment
        @equipment.assign_attributes(
          name: catalog_equipment.name, description: catalog_equipment.description,
          equipment_type: catalog_equipment.equipment_type, cost: catalog_equipment.cost,
          movimiento_modifier: catalog_equipment.movimiento_modifier,
          lucha_modifier: catalog_equipment.lucha_modifier,
          proyectiles_modifier: catalog_equipment.proyectiles_modifier,
          fuerza_modifier: catalog_equipment.fuerza_modifier,
          defensa_modifier: catalog_equipment.defensa_modifier,
          ataques_modifier: catalog_equipment.ataques_modifier,
          heridas_modifier: catalog_equipment.heridas_modifier,
          coraje_modifier: catalog_equipment.coraje_modifier,
          inteligencia_modifier: catalog_equipment.inteligencia_modifier,
          might_modifier: catalog_equipment.might_modifier,
          will_modifier: catalog_equipment.will_modifier,
          fate_modifier: catalog_equipment.fate_modifier
        )
      end
    end
    @catalog_equipments = Equipment.by_name
  end

  def create
    @equipment = @warband_member.warband_equipments.build(equipment_params)

    if @equipment.save
      redirect_to warband_warband_member_warband_equipments_path(@warband_member.warband, @warband_member),
                  notice: "Equipo añadido exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @equipment.update(equipment_params)
      redirect_to warband_warband_member_warband_equipments_path(@warband_member.warband, @warband_member),
                  notice: "Equipo actualizado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @equipment.destroy
    redirect_to warband_warband_member_warband_equipments_path(@warband_member.warband, @warband_member),
                notice: "Equipo eliminado exitosamente"
  end

  private

  def set_warband_member
    @warband_member = WarbandMember.find(params[:warband_member_id])
  end

  def set_equipment
    @equipment = @warband_member.warband_equipments.find(params[:id])
  end

  def authorize_warband_access!
    unless can_manage_warband?(@warband_member.warband)
      redirect_to warbands_path,
                  alert: "No tienes permiso para modificar este equipo"
    end
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
