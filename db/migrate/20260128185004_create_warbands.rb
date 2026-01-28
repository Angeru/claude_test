class CreateWarbands < ActiveRecord::Migration[7.1]
  def change
    create_table :warbands do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.references :campaign, null: true, foreign_key: true

      t.timestamps
    end

    # Índice compuesto único: un usuario solo puede tener una warband por campaña
    # Permite múltiples warbands sin campaña (campaign_id = NULL)
    add_index :warbands, [:user_id, :campaign_id],
              unique: true,
              where: "campaign_id IS NOT NULL",
              name: "index_warbands_on_user_and_campaign"
  end
end
