class AddGoldAndInfluenceToWarbands < ActiveRecord::Migration[7.1]
  def change
    add_column :warbands, :gold, :integer, null: false, default: 0
    add_column :warbands, :influence, :integer, null: false, default: 0
  end
end
