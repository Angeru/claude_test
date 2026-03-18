class AddRankToWarbandMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :warband_members, :rank, :string, default: nil
  end
end
