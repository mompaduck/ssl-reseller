class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :provider
      t.string :product_code
      t.text :description
      t.integer :duration_months
      t.decimal :price
      t.boolean :is_active

      t.timestamps
    end
    add_index :products, :product_code
  end
end
