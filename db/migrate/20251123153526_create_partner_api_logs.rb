class CreatePartnerApiLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :partner_api_logs do |t|
      t.references :order, null: false, foreign_key: true
      t.text :request_body
      t.text :response_body
      t.string :status

      t.timestamps
    end
  end
end
