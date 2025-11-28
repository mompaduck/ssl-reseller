class RemoveContentFromTicketMessages < ActiveRecord::Migration[8.1]
  def change
    remove_column :ticket_messages, :content, :text
  end
end
