class EquipmentsController < ApplicationController
  before_action :require_login
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]

  def index
    @equipments = Equipment.by_name
  end

  def show
  end

  def new
    @equipment = Equipment.new
  end

  def create
    @equipment = Equipment.new(equipment_params)

    if @equipment.save
      redirect_to equipments_path, notice: "Equipamiento añadido al catálogo exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @equipment.update(equipment_params)
      redirect_to equipments_path, notice: "Equipamiento actualizado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @equipment.destroy
    redirect_to equipments_path, notice: "Equipamiento eliminado del catálogo"
  end

  private

  def set_equipment
    @equipment = Equipment.find(params[:id])
  end

  def equipment_params
    params.require(:equipment).permit(
      :name, :description, :equipment_type, :cost, :ranking,
      :movimiento_modifier, :lucha_modifier, :proyectiles_modifier,
      :fuerza_modifier, :defensa_modifier, :ataques_modifier,
      :heridas_modifier, :coraje_modifier, :inteligencia_modifier,
      :might_modifier, :will_modifier, :fate_modifier
    )
  end
end
