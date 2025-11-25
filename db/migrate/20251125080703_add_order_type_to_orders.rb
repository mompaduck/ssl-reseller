class AddOrderTypeToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :order_type, :string, default: 'new', null: false
    add_index :orders, :order_type
  end
end
