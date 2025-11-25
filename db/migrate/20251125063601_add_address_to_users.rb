class AddAddressToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :address, :text unless column_exists?(:users, :address)
  end
end
