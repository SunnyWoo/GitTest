class ChangeActivityDataToJson < ActiveRecord::Migration
  def change
    LogcraftActivity.find_each do |activity|
      if activity.source.blank?
        activity.update(source: '{}')
      else
        hash = YAML.load(activity.source)
        activity.update(source: hash.to_json)
      end

      if activity.extra_info.blank?
        activity.update(extra_info: '{}')
      else
        hash = YAML.load(activity.extra_info)
        activity.update(extra_info: hash.to_json)
      end
    end

    change_column :logcraft_activities, :source, 'json USING source::json', default: {}, null: false
    change_column :logcraft_activities, :extra_info, 'json USING extra_info::json', default: {}, null: false
  end

  class LogcraftActivity < ActiveRecord::Base
  end
end
