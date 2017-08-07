class ChangeLogcraftActivitiesSourceToText < ActiveRecord::Migration
  def up
    change_column :logcraft_activities, :source, :text

    LogcraftActivity.find_each do |activity|
      activity.update(source: {channel: activity.source}.to_yaml)
    end
  end

  def down
    change_column :logcraft_activities, :source, :string

    LogcraftActivity.find_each do |activity|
      activity.update(source: YAML.load(activity.source)[:channel])
    end
  end

  class LogcraftActivity < ActiveRecord::Base
  end
end
