class AddReadAtToTicketMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :ticket_messages, :read_at, :datetime
  end
end
