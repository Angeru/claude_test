class CreateWarbandActivityLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :warband_activity_logs do |t|
      t.integer :warband_id, null: false
      t.integer :warband_member_id
      t.integer :user_id, null: false
      t.string :action, null: false
      t.string :entity_type, null: false
      t.string :entity_name, null: false
      t.text :changes_summary

      t.timestamps
    end
    add_index :warband_activity_logs, :warband_id
    add_index :warband_activity_logs, :created_at
  end
end
