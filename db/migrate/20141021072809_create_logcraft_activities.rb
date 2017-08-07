class CreateLogcraftActivities < ActiveRecord::Migration
  def change
    create_table :logcraft_activities do |t|
      t.string :key
      t.belongs_to :trackable, polymorphic: true, index: true
      t.belongs_to :user, polymorphic: true, index: true
      t.string :source
      t.text :message
      t.text :extra_info

      t.timestamps
    end
  end
end
