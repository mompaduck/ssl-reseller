class UpdateUserRoleToEnum < ActiveRecord::Migration[8.1]
  def up
    # Change role column from string to integer for MySQL
    execute "ALTER TABLE users MODIFY COLUMN role INT DEFAULT 0"
    # Set all existing NULL values to 0 (user)
    execute "UPDATE users SET role = 0 WHERE role IS NULL"
  end

  def down
    execute "ALTER TABLE users MODIFY COLUMN role VARCHAR(255)"
  end
end
