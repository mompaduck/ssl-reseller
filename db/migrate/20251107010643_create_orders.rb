class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :status
      t.string :domain
      t.text :csr
      t.string :validation_method
      t.string :internal_order_id
      t.string :partner_order_number
      t.datetime :issued_at
      t.datetime :expires_at

      t.timestamps
    end
    add_index :orders, :internal_order_id
    add_index :orders, :partner_order_number
  end
end
