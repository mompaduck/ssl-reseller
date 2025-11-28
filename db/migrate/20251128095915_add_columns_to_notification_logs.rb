class AddColumnsToNotificationLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :notification_logs, :user_id, :bigint
    add_column :notification_logs, :message_preview, :string, limit: 200
    add_column :notification_logs, :error_message, :text
    add_column :notification_logs, :sender_id, :bigint
    add_column :notification_logs, :ip_address, :string, limit: 45
    add_column :notification_logs, :related_ticket_id, :bigint
    add_column :notification_logs, :related_order_id, :bigint
    add_column :notification_logs, :related_certificate_id, :bigint
    
    # Add indexes for better query performance
    add_index :notification_logs, :user_id
    add_index :notification_logs, :sender_id
    add_index :notification_logs, :related_ticket_id
    add_index :notification_logs, :related_order_id
    add_index :notification_logs, :related_certificate_id
    add_index :notification_logs, [:status, :sent_at]
    add_index :notification_logs, [:notification_type, :created_at]
    
    # Add foreign keys
    add_foreign_key :notification_logs, :users, column: :user_id
    add_foreign_key :notification_logs, :users, column: :sender_id
    add_foreign_key :notification_logs, :tickets, column: :related_ticket_id
    add_foreign_key :notification_logs, :orders, column: :related_order_id
    add_foreign_key :notification_logs, :certificates, column: :related_certificate_id
  end
end
