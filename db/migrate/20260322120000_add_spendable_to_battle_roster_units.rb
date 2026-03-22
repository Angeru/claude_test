class AddSpendableToBattleRosterUnits < ActiveRecord::Migration[7.1]
  def change
    add_column :battle_roster_units, :current_might, :integer, default: 0, null: false
    add_column :battle_roster_units, :current_will,  :integer, default: 0, null: false
    add_column :battle_roster_units, :current_fate,  :integer, default: 0, null: false
  end
end
