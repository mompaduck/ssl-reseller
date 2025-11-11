class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string   :name,            null: false
      t.string   :provider,        null: false, default: ""
      t.string   :product_code,    null: false
      t.text     :description
      t.integer  :duration_months, null: false, default: 12
      t.integer  :price,           null: false, default: 0
      t.integer  :domain_count,    null: false, default: 1
      t.string   :cert_type,       null: false, default: "single"      # Single/Wildcard/Multi
      t.string   :validation_type, null: false, default: "DV"          # DV/OV/EV 등
      t.integer  :liability_usd,   null: false, default: 0
      t.integer  :discount,        null: false, default: 0
      t.boolean  :multi_year_support, null: false, default: false
      t.string   :logo_url
      t.string   :warranty_url
      t.string   :brand_site_url
      t.text     :features
      t.boolean  :is_active,        null: false, default: true

      t.timestamps
    end

    add_index :products, :product_code, unique: true
    add_index :products, [:provider, :name], name: "index_products_on_provider_and_name"
    add_index :products, :cert_type
    add_index :products, :validation_type
  end
end