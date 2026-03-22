class AddObjectiveAndMvpToBattleRosterUnits < ActiveRecord::Migration[7.1]
  def change
    add_column :battle_roster_units, :on_objective, :boolean, default: false, null: false
    add_column :battle_roster_units, :mvp, :boolean, default: false, null: false
  end
end
