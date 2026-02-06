class CreateBattleRosterUnits < ActiveRecord::Migration[7.1]
  def change
    create_table :battle_roster_units do |t|
      t.references :battle_roster, null: false, foreign_key: true
      t.references :warband_member, null: false, foreign_key: true
      t.integer :current_wounds, null: false, default: 1
      t.integer :max_wounds, null: false, default: 1
      t.boolean :defeated, default: false, null: false

      t.timestamps
    end

    add_index :battle_roster_units, [:battle_roster_id, :warband_member_id], unique: true, name: 'idx_battle_roster_units_on_roster_and_member'
  end
end
