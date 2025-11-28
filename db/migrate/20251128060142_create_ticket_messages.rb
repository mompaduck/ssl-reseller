class CreateTicketMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_messages do |t|
      t.references :ticket, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: true
      t.integer :message_type, null: false
      t.text :content, null: false
      t.boolean :is_read, null: false, default: false

      t.timestamps
    end
    add_index :ticket_messages, [:ticket_id, :created_at]
    add_index :ticket_messages, [:ticket_id, :message_type]
  end
end
