class RenameCaminoToPathInWarbandMembers < ActiveRecord::Migration[7.1]
  def change
    rename_column :warband_members, :camino, :path
  end
end
