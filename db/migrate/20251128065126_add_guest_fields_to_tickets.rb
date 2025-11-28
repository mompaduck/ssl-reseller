class AddGuestFieldsToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :guest_name, :string
    add_column :tickets, :guest_email, :string
    add_column :tickets, :guest_phone, :string
    
    add_index :tickets, :guest_email
  end
end
