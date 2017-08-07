class CreateAnnouncements < ActiveRecord::Migration
  def up
    create_table :announcements do |t|
      t.text :message
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :default, default: false

      t.timestamps
    end
    Announcement.create_translation_table! message: :text
  end

  def down
    drop_table! :announcements
    Announcement.drop_translation_table!
  end
end
