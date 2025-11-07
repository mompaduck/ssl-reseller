class CreateCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :certificates do |t|
      t.references :order, null: false, foreign_key: true
      t.string :serial_number
      t.text :certificate_body
      t.text :ca_bundle
      t.text :private_key_encrypted
      t.string :status
      t.datetime :issued_at
      t.datetime :expires_at
      t.datetime :revoked_at

      t.timestamps
    end
    add_index :certificates, :serial_number
  end
end
