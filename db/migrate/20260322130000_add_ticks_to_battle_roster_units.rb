class AddTicksToBattleRosterUnits < ActiveRecord::Migration[7.1]
  def change
    add_column :battle_roster_units, :wounded_enemy,  :boolean, default: false, null: false
    add_column :battle_roster_units, :fate_protected, :boolean, default: false, null: false
    add_column :battle_roster_units, :courage_broken, :boolean, default: false, null: false
  end
end
