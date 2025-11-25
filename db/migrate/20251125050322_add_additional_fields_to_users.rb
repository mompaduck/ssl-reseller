class AddAdditionalFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :department, :string
    add_column :users, :failed_attempts, :integer, default: 0, null: false
    add_column :users, :locked_at, :datetime
    add_column :users, :two_factor_enabled, :boolean, default: false, null: false
  end
end
