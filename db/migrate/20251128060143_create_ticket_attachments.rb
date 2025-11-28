class CreateTicketAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_attachments do |t|
      t.references :ticket_message, null: false, foreign_key: { on_delete: :cascade }
      t.string :filename, null: false
      t.integer :filesize, null: false, unsigned: true
      t.string :mime_type, null: false
      t.string :storage_path, null: false, limit: 500
      t.integer :virus_scan_status, default: 0 # pending
      t.datetime :virus_scan_at

      t.timestamps
    end
  end
end
