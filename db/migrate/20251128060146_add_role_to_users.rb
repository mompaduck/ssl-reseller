class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    # role column already exists, just adding index
    add_index :users, :role unless index_exists?(:users, :role)
  end
end
