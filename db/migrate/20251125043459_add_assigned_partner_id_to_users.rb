class AddAssignedPartnerIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :assigned_partner_id, :integer
  end
end
