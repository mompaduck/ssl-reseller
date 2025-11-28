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

ActiveRecord::Schema[8.1].define(version: 2025_11_28_110539) do
  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body", size: :long
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "certificate_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action"
    t.bigint "certificate_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.text "message"
    t.json "metadata"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["certificate_id"], name: "index_certificate_logs_on_certificate_id"
    t.index ["user_id"], name: "index_certificate_logs_on_user_id"
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

  create_table "notification_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "ip_address", limit: 45
    t.text "message"
    t.string "message_preview", limit: 200
    t.json "metadata"
    t.integer "notification_type"
    t.string "recipient"
    t.bigint "related_certificate_id"
    t.bigint "related_order_id"
    t.bigint "related_ticket_id"
    t.bigint "sender_id"
    t.datetime "sent_at"
    t.integer "status"
    t.string "subject"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["notification_type", "created_at"], name: "index_notification_logs_on_notification_type_and_created_at"
    t.index ["related_certificate_id"], name: "index_notification_logs_on_related_certificate_id"
    t.index ["related_order_id"], name: "index_notification_logs_on_related_order_id"
    t.index ["related_ticket_id"], name: "index_notification_logs_on_related_ticket_id"
    t.index ["sender_id"], name: "index_notification_logs_on_sender_id"
    t.index ["status", "sent_at"], name: "index_notification_logs_on_status_and_sent_at"
    t.index ["user_id"], name: "index_notification_logs_on_user_id"
  end

  create_table "order_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.text "message"
    t.json "metadata"
    t.bigint "order_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["order_id"], name: "index_order_logs_on_order_id"
    t.index ["user_id"], name: "index_order_logs_on_user_id"
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
    t.integer "cost_price", default: 0, null: false, comment: "Sectigo 원가"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "discount"
    t.integer "domain_count"
    t.integer "domain_type"
    t.integer "duration_months"
    t.text "features"
    t.boolean "is_active"
    t.boolean "is_on_promotion", default: false, comment: "프로모션 활성화 여부"
    t.integer "liability_usd"
    t.string "logo_url"
    t.decimal "margin_percentage", precision: 5, scale: 2, comment: "마진율 (%)"
    t.boolean "multi_year_support"
    t.string "name"
    t.string "product_code"
    t.string "promo_code", comment: "프로모션 코드"
    t.datetime "promo_valid_until", comment: "프로모션 종료일"
    t.string "provider"
    t.integer "selling_price"
    t.datetime "updated_at", null: false
    t.integer "validation_type"
    t.string "warranty_url"
    t.index ["cost_price"], name: "index_products_on_cost_price"
    t.index ["is_on_promotion"], name: "index_products_on_is_on_promotion"
    t.index ["promo_code"], name: "index_products_on_promo_code"
  end

  create_table "settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key"
    t.datetime "updated_at", null: false
    t.text "value"
  end

  create_table "system_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "level"
    t.text "message"
    t.json "metadata"
    t.string "source"
    t.text "stack_trace"
    t.datetime "updated_at", null: false
  end

  create_table "ticket_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.integer "filesize", null: false, unsigned: true
    t.string "mime_type", null: false
    t.string "storage_path", limit: 500, null: false
    t.bigint "ticket_message_id", null: false
    t.datetime "updated_at", null: false
    t.datetime "virus_scan_at"
    t.integer "virus_scan_status", default: 0
    t.index ["ticket_message_id"], name: "index_ticket_attachments_on_ticket_message_id"
  end

  create_table "ticket_messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_read", default: false, null: false
    t.integer "message_type", null: false
    t.datetime "read_at"
    t.bigint "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["ticket_id", "created_at"], name: "index_ticket_messages_on_ticket_id_and_created_at"
    t.index ["ticket_id", "message_type"], name: "index_ticket_messages_on_ticket_id_and_message_type"
    t.index ["ticket_id"], name: "index_ticket_messages_on_ticket_id"
    t.index ["user_id"], name: "index_ticket_messages_on_user_id"
  end

  create_table "ticket_templates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "category", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "usage_count", default: 0, null: false, unsigned: true
    t.index ["category"], name: "index_ticket_templates_on_category"
    t.index ["created_by_id"], name: "index_ticket_templates_on_created_by_id"
    t.index ["usage_count"], name: "index_ticket_templates_on_usage_count", order: :desc
  end

  create_table "tickets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "assigned_to_id"
    t.integer "category", default: 5, null: false
    t.bigint "certificate_id"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.datetime "first_response_at"
    t.string "guest_email"
    t.string "guest_name"
    t.string "guest_phone"
    t.bigint "order_id"
    t.integer "priority", default: 0, null: false
    t.text "satisfaction_comment"
    t.integer "satisfaction_rating", limit: 1
    t.string "status", default: "new", null: false
    t.string "subject", null: false
    t.string "ticket_number", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["assigned_to_id", "status"], name: "index_tickets_on_assigned_to_id_and_status"
    t.index ["assigned_to_id"], name: "index_tickets_on_assigned_to_id"
    t.index ["certificate_id"], name: "index_tickets_on_certificate_id"
    t.index ["deleted_at"], name: "index_tickets_on_deleted_at"
    t.index ["guest_email"], name: "index_tickets_on_guest_email"
    t.index ["order_id"], name: "index_tickets_on_order_id"
    t.index ["priority", "created_at"], name: "index_tickets_on_priority_and_created_at", order: :desc
    t.index ["status", "created_at"], name: "index_tickets_on_status_and_created_at"
    t.index ["subject"], name: "idx_subject", type: :fulltext
    t.index ["ticket_number"], name: "index_tickets_on_ticket_number", unique: true
    t.index ["user_id", "status"], name: "index_tickets_on_user_id_and_status"
    t.index ["user_id"], name: "index_tickets_on_user_id"
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
    t.string "english_name"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name"
    t.json "notification_settings"
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
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "certificate_logs", "certificates"
  add_foreign_key "certificate_logs", "users"
  add_foreign_key "certificates", "orders"
  add_foreign_key "certificates", "users"
  add_foreign_key "notification_logs", "certificates", column: "related_certificate_id"
  add_foreign_key "notification_logs", "orders", column: "related_order_id"
  add_foreign_key "notification_logs", "tickets", column: "related_ticket_id"
  add_foreign_key "notification_logs", "users"
  add_foreign_key "notification_logs", "users", column: "sender_id"
  add_foreign_key "order_logs", "orders"
  add_foreign_key "order_logs", "users"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "partner_api_logs", "orders"
  add_foreign_key "payments", "orders"
  add_foreign_key "ticket_attachments", "ticket_messages", on_delete: :cascade
  add_foreign_key "ticket_messages", "tickets", on_delete: :cascade
  add_foreign_key "ticket_messages", "users"
  add_foreign_key "ticket_templates", "users", column: "created_by_id"
  add_foreign_key "tickets", "certificates"
  add_foreign_key "tickets", "orders"
  add_foreign_key "tickets", "users"
  add_foreign_key "tickets", "users", column: "assigned_to_id"
end
