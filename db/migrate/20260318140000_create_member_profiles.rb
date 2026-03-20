class CreateMemberProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :member_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :member_type, default: "warrior", null: false
      t.string :rank
      t.integer :movimiento, default: 6, null: false
      t.integer :lucha, default: 3, null: false
      t.integer :proyectiles, default: 3, null: false
      t.integer :fuerza, default: 3, null: false
      t.integer :defensa, default: 3, null: false
      t.integer :ataques, default: 1, null: false
      t.integer :heridas, default: 1, null: false
      t.integer :coraje, default: 3, null: false
      t.integer :inteligencia, default: 1, null: false
      t.integer :might, default: 0, null: false
      t.integer :will, default: 0, null: false
      t.integer :fate, default: 0, null: false
      t.integer :experience, default: 0, null: false
      t.integer :ranking, default: 0, null: false

      t.timestamps
    end

    add_index :member_profiles, :member_type
  end
end
