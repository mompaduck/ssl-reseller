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

ActiveRecord::Schema[8.1].define(version: 2025_11_07_043148) do
  create_table "certificates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "ca_bundle"
    t.text "certificate_body"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.datetime "issued_at"
    t.bigint "order_id", null: false
    t.text "private_key_encrypted"
    t.datetime "revoked_at"
    t.string "serial_number"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_certificates_on_order_id"
    t.index ["serial_number"], name: "index_certificates_on_serial_number"
  end

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
    t.string "phone"
    t.bigint "product_id", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "validation_method"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "partner_api_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "endpoint"
    t.string "error_code"
    t.string "error_message"
    t.bigint "order_id", null: false
    t.string "partner_name"
    t.text "request_body"
    t.text "response_body"
    t.integer "status_code"
    t.boolean "success"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_partner_api_logs_on_order_id"
  end

  create_table "payments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "amount", precision: 10
    t.datetime "created_at", null: false
    t.string "currency"
    t.bigint "order_id", null: false
    t.datetime "paid_at"
    t.string "payment_method"
    t.string "status"
    t.string "transaction_id"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["transaction_id"], name: "index_payments_on_transaction_id"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_months"
    t.boolean "is_active"
    t.string "name"
    t.decimal "price", precision: 10
    t.string "product_code"
    t.string "provider"
    t.datetime "updated_at", null: false
    t.index ["product_code"], name: "index_products_on_product_code"
  end

  create_table "resellers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "api_key"
    t.decimal "balance", precision: 10
    t.string "business_id"
    t.decimal "commission_rate", precision: 10
    t.string "company_name"
    t.datetime "created_at", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "verified"
    t.datetime "verified_at"
    t.index ["api_key"], name: "index_resellers_on_api_key"
    t.index ["user_id"], name: "index_resellers_on_user_id"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "settlements", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "approved_at"
    t.decimal "commission_amount", precision: 10
    t.decimal "commission_rate", precision: 10
    t.datetime "created_at", null: false
    t.date "period_end"
    t.date "period_start"
    t.string "status"
    t.decimal "total_sales", precision: 10
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_settlements_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "api_token"
    t.string "company_name"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
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

  create_table "webhook_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type"
    t.text "payload"
    t.boolean "processed"
    t.datetime "processed_at"
    t.integer "resource_id"
    t.string "resource_type"
    t.string "source"
    t.datetime "updated_at", null: false
    t.index ["resource_id"], name: "index_webhook_events_on_resource_id"
  end

  add_foreign_key "certificates", "orders"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "partner_api_logs", "orders"
  add_foreign_key "payments", "orders"
  add_foreign_key "resellers", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "settlements", "users"
end
