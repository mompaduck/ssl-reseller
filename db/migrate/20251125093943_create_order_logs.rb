class CreateOrderLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :order_logs do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :action
      t.text :message
      t.json :metadata
      t.string :ip_address

      t.timestamps
    end
  end
end
