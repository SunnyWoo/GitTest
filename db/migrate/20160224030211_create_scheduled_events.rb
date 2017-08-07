class CreateScheduledEvents < ActiveRecord::Migration
  def change
    create_table :scheduled_events do |t|
      t.string :name
      t.datetime :scheduled_at
      t.boolean :executed, default: false
      t.json :extra_info

      t.timestamps
    end

    add_index :scheduled_events, [:name], unique: true
  end
end
