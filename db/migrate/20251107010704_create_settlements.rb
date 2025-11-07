class CreateSettlements < ActiveRecord::Migration[8.1]
  def change
    create_table :settlements do |t|
      t.references :user, null: false, foreign_key: true
      t.date :period_start
      t.date :period_end
      t.decimal :total_sales
      t.decimal :commission_rate
      t.decimal :commission_amount
      t.string :status
      t.datetime :approved_at

      t.timestamps
    end
  end
end
