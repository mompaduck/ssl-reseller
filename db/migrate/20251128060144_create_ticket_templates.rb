class CreateTicketTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_templates do |t|
      t.string :name, null: false
      t.integer :category, null: false
      t.text :content, null: false
      t.integer :usage_count, null: false, default: 0, unsigned: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :ticket_templates, :category
    add_index :ticket_templates, :usage_count, order: :desc
  end
end
