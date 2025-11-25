class CreateSystemLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :system_logs do |t|
      t.integer :level
      t.string :source
      t.text :message
      t.json :metadata
      t.text :stack_trace

      t.timestamps
    end
  end
end
