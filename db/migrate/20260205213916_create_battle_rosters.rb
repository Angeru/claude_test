class CreateBattleRosters < ActiveRecord::Migration[7.1]
  def change
    create_table :battle_rosters do |t|
      t.references :matchup, null: false, foreign_key: true
      t.references :warband, null: false, foreign_key: true
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :battle_rosters, [:matchup_id, :warband_id], unique: true
  end
end
