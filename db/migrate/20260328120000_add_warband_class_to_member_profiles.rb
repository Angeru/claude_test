class AddWarbandClassToMemberProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :member_profiles, :warband_class, :string
    add_index :member_profiles, :warband_class
  end
end
