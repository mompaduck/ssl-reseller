class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :payment_method
      t.decimal :amount
      t.string :currency
      t.string :transaction_id
      t.string :status
      t.datetime :paid_at

      t.timestamps
    end
    add_index :payments, :transaction_id
  end
end
