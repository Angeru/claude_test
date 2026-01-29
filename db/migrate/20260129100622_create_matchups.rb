class CreateMatchups < ActiveRecord::Migration[7.1]
  def change
    create_table :matchups do |t|
      t.references :campaign_round, null: false, foreign_key: true
      t.integer :warband_1_id, null: false
      t.integer :warband_2_id, null: false
      t.integer :warband_1_score, default: 0
      t.integer :warband_2_score, default: 0
      t.integer :warband_1_casualties, default: 0
      t.integer :warband_2_casualties, default: 0
      t.boolean :warband_1_primary_objective, default: false
      t.boolean :warband_2_primary_objective, default: false
      t.boolean :warband_1_secondary_objective, default: false
      t.boolean :warband_2_secondary_objective, default: false
      t.integer :winner_id
      t.string :result
      t.text :notes

      t.timestamps
    end

    add_foreign_key :matchups, :warbands, column: :warband_1_id
    add_foreign_key :matchups, :warbands, column: :warband_2_id
    add_foreign_key :matchups, :warbands, column: :winner_id
    add_index :matchups, :warband_1_id
    add_index :matchups, :warband_2_id
    add_index :matchups, :result
  end
end
