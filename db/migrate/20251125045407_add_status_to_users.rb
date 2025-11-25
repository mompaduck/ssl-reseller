class AddStatusToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :status, :integer, default: 0, null: false
  end
end
