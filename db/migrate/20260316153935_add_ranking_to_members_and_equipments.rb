class AddRankingToMembersAndEquipments < ActiveRecord::Migration[7.1]
  def change
    add_column :warband_members, :ranking, :integer, default: 0, null: false
    add_column :warband_equipments, :ranking, :integer, default: 0, null: false
    add_column :equipments, :ranking, :integer, default: 0, null: false
  end
end
