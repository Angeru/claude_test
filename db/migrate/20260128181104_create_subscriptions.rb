class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :campaign, null: false, foreign_key: true
      t.datetime :subscribed_at, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end

    add_index :subscriptions, [:user_id, :campaign_id], unique: true
  end
end
