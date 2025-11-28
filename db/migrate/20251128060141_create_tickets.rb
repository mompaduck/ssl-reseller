class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.string :ticket_number, null: false
      t.references :user, null: false, foreign_key: true
      t.references :assigned_to, null: true, foreign_key: { to_table: :users }
      t.references :order, null: true, foreign_key: true
      t.references :certificate, null: true, foreign_key: true
      t.integer :category, null: false, default: 5 # general
      t.integer :priority, null: false, default: 0 # normal
      t.string :status, null: false, default: 'new'
      t.string :subject, null: false
      t.integer :satisfaction_rating, limit: 1
      t.text :satisfaction_comment
      t.datetime :first_response_at
      t.datetime :closed_at
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :tickets, :ticket_number, unique: true
    add_index :tickets, [:user_id, :status]
    add_index :tickets, [:assigned_to_id, :status]
    add_index :tickets, [:priority, :created_at], order: { priority: :desc, created_at: :desc }
    add_index :tickets, [:status, :created_at]
    add_index :tickets, :deleted_at
    # Fulltext index usually requires specific SQL for MySQL
    execute "CREATE FULLTEXT INDEX idx_subject ON tickets (subject)"
  end
end
