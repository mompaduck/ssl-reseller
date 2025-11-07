class CreateWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_events do |t|
      t.string :event_type
      t.string :source
      t.text :payload
      t.boolean :processed
      t.datetime :processed_at
      t.string :resource_type
      t.integer :resource_id

      t.timestamps
    end
    add_index :webhook_events, :resource_id
  end
end
