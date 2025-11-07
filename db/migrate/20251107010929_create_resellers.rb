class CreateResellers < ActiveRecord::Migration[8.1]
  def change
    create_table :resellers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company_name
      t.string :business_id
      t.string :api_key
      t.decimal :commission_rate
      t.decimal :balance
      t.string :status
      t.boolean :verified
      t.datetime :verified_at

      t.timestamps
    end
    add_index :resellers, :api_key
  end
end
