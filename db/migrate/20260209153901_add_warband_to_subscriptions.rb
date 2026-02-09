class AddWarbandToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_reference :subscriptions, :warband, null: true, foreign_key: true
  end
end
