class AddHeroInjuriesToWarbandMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :warband_members, :arm_injured, :boolean, default: false, null: false
    add_column :warband_members, :leg_injured, :boolean, default: false, null: false
    add_column :warband_members, :disgrace_count, :integer, default: 0, null: false
  end
end
