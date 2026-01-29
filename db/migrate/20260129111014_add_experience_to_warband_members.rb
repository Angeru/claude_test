class AddExperienceToWarbandMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :warband_members, :experience, :integer, null: false, default: 0
  end
end
