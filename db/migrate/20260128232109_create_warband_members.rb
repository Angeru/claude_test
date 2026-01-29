class CreateWarbandMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :warband_members do |t|
      t.references :warband, null: false, foreign_key: true
      t.string :name, null: false
      t.string :member_type, null: false, default: "warrior"

      # Combat attributes
      t.integer :movimiento, null: false, default: 6
      t.integer :lucha, null: false, default: 3
      t.integer :proyectiles, null: false, default: 3
      t.integer :fuerza, null: false, default: 3
      t.integer :defensa, null: false, default: 3
      t.integer :ataques, null: false, default: 1
      t.integer :heridas, null: false, default: 1
      t.integer :coraje, null: false, default: 3
      t.integer :inteligencia, null: false, default: 1
      t.integer :might, null: false, default: 0
      t.integer :will, null: false, default: 0
      t.integer :fate, null: false, default: 0

      t.timestamps
    end

    add_index :warband_members, :member_type
  end
end
