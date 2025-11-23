class AddNameFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :name, :string
    add_column :orders, :english_name, :string
  end
end
