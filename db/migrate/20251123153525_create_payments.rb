class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :amount
      t.string :payment_method
      t.integer :status
      t.string :transaction_id

      t.timestamps
    end
  end
end
