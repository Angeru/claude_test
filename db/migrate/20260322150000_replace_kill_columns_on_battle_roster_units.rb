class ReplaceKillColumnsOnBattleRosterUnits < ActiveRecord::Migration[7.1]
  def change
    remove_column :battle_roster_units, :heroes_killed,   :integer
    remove_column :battle_roster_units, :monsters_killed, :integer
    add_column    :battle_roster_units, :kills,           :integer, default: 0, null: false
  end
end
