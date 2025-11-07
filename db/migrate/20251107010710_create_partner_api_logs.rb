class CreatePartnerApiLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :partner_api_logs do |t|
      t.string :partner_name
      t.string :endpoint
      t.text :request_body
      t.text :response_body
      t.integer :status_code
      t.boolean :success
      t.references :order, null: false, foreign_key: true
      t.string :error_code
      t.string :error_message

      t.timestamps
    end
  end
end
