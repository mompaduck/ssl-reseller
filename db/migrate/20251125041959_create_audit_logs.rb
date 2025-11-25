class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :auditable, polymorphic: true, null: false
      t.string :action
      t.text :message
      t.json :metadata
      t.string :ip_address

      t.timestamps
    end
  end
end
