class CreateNotificationTrackings < ActiveRecord::Migration
  def change
    create_table :notification_trackings do |t|
      t.belongs_to :notification, index: true
      t.belongs_to :user, index: true
      t.string     :device_token
      t.string     :country_code
      t.datetime   :opened_at
      t.hstore       :extra_info
      t.timestamps
    end
  end
end
