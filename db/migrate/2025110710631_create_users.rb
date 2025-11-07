class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :company_name
      t.string :phone
      t.string :country
      t.string :role
      t.string :email
      t.string :encrypted_password
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      t.string :api_token

      t.timestamps
    end
    add_index :users, :email
    add_index :users, :reset_password_token
    add_index :users, :confirmation_token
    add_index :users, :api_token
  end
end
