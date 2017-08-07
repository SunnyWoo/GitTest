class CreateBdevents < ActiveRecord::Migration
  def up
    create_table :bdevents do |t|
      t.string :uuid
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :priority, default: 1
      t.boolean :is_enabled
      t.integer :event_type, default: 0

      t.timestamps
    end
    add_index :bdevents, :is_enabled
    add_index :bdevents, :event_type

    Bdevent.create_translation_table!({ title: :string,
                                        desc: :text,
                                        banner: :string,
                                        coming_soon_image: :string})
  end

  def down
    drop_table :bdevents
    Bdevent.drop_translation_table!
  end
end
