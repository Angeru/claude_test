class CreateWarbandEquipments < ActiveRecord::Migration[7.1]
  def change
    create_table :warband_equipments do |t|
      t.references :warband_member, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :equipment_type, null: false
      t.integer :cost, null: false, default: 0
      t.integer :movimiento_modifier, null: false, default: 0
      t.integer :lucha_modifier, null: false, default: 0
      t.integer :proyectiles_modifier, null: false, default: 0
      t.integer :fuerza_modifier, null: false, default: 0
      t.integer :defensa_modifier, null: false, default: 0
      t.integer :ataques_modifier, null: false, default: 0
      t.integer :heridas_modifier, null: false, default: 0
      t.integer :coraje_modifier, null: false, default: 0
      t.integer :inteligencia_modifier, null: false, default: 0
      t.integer :might_modifier, null: false, default: 0
      t.integer :will_modifier, null: false, default: 0
      t.integer :fate_modifier, null: false, default: 0

      t.timestamps
    end

    add_index :warband_equipments, :equipment_type
  end
end
