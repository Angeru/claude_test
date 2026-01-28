class CreateCampaigns < ActiveRecord::Migration[7.1]
  def change
    create_table :campaigns do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.references :user, null: false, foreign_key: true
      t.string :status, default: "activa", null: false
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end

    add_index :campaigns, :status
    add_index :campaigns, :start_date
    add_index :campaigns, :end_date
  end
end
