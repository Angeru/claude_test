class AddWarbandClassToWarbands < ActiveRecord::Migration[7.1]
  def change
    add_column :warbands, :warband_class, :string
  end
end
