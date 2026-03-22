class AddCaminoToWarbandMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :warband_members, :camino, :string, default: nil
  end
end
