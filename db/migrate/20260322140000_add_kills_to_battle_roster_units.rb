class AddKillsToBattleRosterUnits < ActiveRecord::Migration[7.1]
  def change
    add_column :battle_roster_units, :heroes_killed,   :integer, default: 0, null: false
    add_column :battle_roster_units, :monsters_killed, :integer, default: 0, null: false
  end
end
