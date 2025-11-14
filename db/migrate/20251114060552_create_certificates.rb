class CreateCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :certificates do |t|
      t.string :serial_number
      t.text :certificate_body
      t.text :private_key
      t.datetime :issued_at
      t.datetime :expires_at
      t.datetime :revoked_at
      t.integer :status, null: false, default: 0
      t.integer :certificate_type, null: false, default: 0
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :certificates, :serial_number
  end
end
