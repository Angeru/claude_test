class AddDeadAndInjuredToWarbandMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :warband_members, :dead, :boolean, default: false, null: false
    add_column :warband_members, :injured, :boolean, default: false, null: false
  end
end
