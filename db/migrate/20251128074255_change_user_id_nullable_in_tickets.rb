class ChangeUserIdNullableInTickets < ActiveRecord::Migration[8.1]
  def change
    change_column_null :tickets, :user_id, true
  end
end
