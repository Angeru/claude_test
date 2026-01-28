class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :name
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
