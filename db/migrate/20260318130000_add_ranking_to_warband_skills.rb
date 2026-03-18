class AddRankingToWarbandSkills < ActiveRecord::Migration[7.1]
  def change
    add_column :warband_skills, :ranking, :integer, default: 0, null: false
  end
end
