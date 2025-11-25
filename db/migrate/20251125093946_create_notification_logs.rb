class CreateNotificationLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_logs do |t|
      t.string :recipient
      t.integer :notification_type
      t.string :subject
      t.text :message
      t.integer :status
      t.datetime :sent_at
      t.json :metadata

      t.timestamps
    end
  end
end
