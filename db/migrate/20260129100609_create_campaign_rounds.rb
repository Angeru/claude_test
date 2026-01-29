class CreateCampaignRounds < ActiveRecord::Migration[7.1]
  def change
    create_table :campaign_rounds do |t|
      t.references :campaign, null: false, foreign_key: true
      t.integer :round_number, null: false
      t.date :played_at
      t.string :scenario

      t.timestamps
    end

    add_index :campaign_rounds, [:campaign_id, :round_number], unique: true
  end
end
