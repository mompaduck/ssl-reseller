class AddEnglishNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :english_name, :string
  end
end
