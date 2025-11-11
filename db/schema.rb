# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_11_111300) do
  create_table "orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "certificate_type"
    t.string "company_address"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.text "csr"
    t.string "domain"
    t.datetime "expires_at"
    t.string "internal_order_id"
    t.datetime "issued_at"
    t.string "partner_order_number"
    t.string "payment_method"
    t.string "phone"
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.string "status"
    t.integer "total_price"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "validation_method"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "brand_site_url"
    t.string "cert_type"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "discount"
    t.integer "domain_count"
    t.integer "duration_months"
    t.text "features"
    t.boolean "is_active"
    t.integer "liability_usd"
    t.string "logo_url"
    t.boolean "multi_year_support"
    t.string "name"
    t.integer "price"
    t.string "product_code"
    t.string "provider"
    t.datetime "updated_at", null: false
    t.string "validation_type"
    t.string "warranty_url"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "api_token"
    t.string "company_name"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "encrypted_password"
    t.string "name"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.boolean "terms"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
end
