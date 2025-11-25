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

ActiveRecord::Schema[8.1].define(version: 2025_11_25_083900) do
  create_table "audit_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action"
    t.bigint "auditable_id", null: false
    t.string "auditable_type", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.text "message"
    t.json "metadata"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "certificates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "certificate_body"
    t.integer "certificate_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.json "csr_parsed_data"
    t.string "dcv_cname_host"
    t.string "dcv_cname_value"
    t.string "dcv_email"
    t.text "dcv_file_content"
    t.string "dcv_file_url"
    t.string "dcv_method"
    t.datetime "expires_at"
    t.text "failure_reason"
    t.datetime "issued_at"
    t.bigint "order_id", null: false
    t.text "private_key"
    t.datetime "revoked_at"
    t.string "serial_number"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["order_id"], name: "index_certificates_on_order_id"
    t.index ["serial_number"], name: "index_certificates_on_serial_number"
    t.index ["user_id"], name: "index_certificates_on_user_id"
  end

  create_table "orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "certificate_type"
    t.string "company_address"
    t.string "company_name"
    t.datetime "created_at", null: false
    t.text "csr"
    t.string "domain"
    t.string "english_name"
    t.datetime "expires_at"
    t.string "internal_order_id"
    t.datetime "issued_at"
    t.string "name"
    t.string "order_type", default: "new", null: false
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
    t.index ["order_type"], name: "index_orders_on_order_type"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "partner_api_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_partner_api_logs_on_order_id"
  end

  create_table "payments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "amount"
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.string "payment_method"
    t.integer "status"
    t.string "transaction_id"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "brand_site_url"
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "discount"
    t.integer "domain_count"
    t.integer "domain_type"
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
    t.integer "validation_type"
    t.string "warranty_url"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "address"
    t.boolean "admin", default: false
    t.string "api_token"
    t.integer "assigned_partner_id"
    t.string "company_name"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.datetime "deleted_at"
    t.string "department"
    t.string "email"
    t.string "encrypted_password"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name"
    t.string "phone"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.integer "sign_in_count", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.boolean "terms"
    t.boolean "two_factor_enabled", default: false, null: false
    t.string "uid"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  add_foreign_key "audit_logs", "users"
  add_foreign_key "certificates", "orders"
  add_foreign_key "certificates", "users"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "partner_api_logs", "orders"
  add_foreign_key "payments", "orders"
end
