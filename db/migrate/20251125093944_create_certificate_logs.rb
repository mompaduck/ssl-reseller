class CreateCertificateLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :certificate_logs do |t|
      t.references :certificate, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :action
      t.text :message
      t.json :metadata
      t.string :ip_address

      t.timestamps
    end
  end
end
