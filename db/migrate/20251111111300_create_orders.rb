class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :certificate_type
      t.string :domain
      t.string :company_name
      t.string :phone
      t.string :company_address
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :status
      t.text :csr
      t.string :validation_method
      t.string :internal_order_id
      t.string :partner_order_number
      t.datetime :issued_at
      t.datetime :expires_at
      t.integer :quantity
      t.integer :total_price
      t.string :payment_method

      t.timestamps
    end
  end
end
