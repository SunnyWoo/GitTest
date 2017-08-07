class RemoveNullFalseFromLogrcraftActivities < ActiveRecord::Migration
  def up
    change_column :logcraft_activities, :source, :json, default: {}, null: true
    change_column :logcraft_activities, :extra_info, :json, default: {}, null: true
  end

  def down
    change_column :logcraft_activities, :extra_info, :json, default: {}, null: false
    change_column :logcraft_activities, :source, :json, default: {}, null: false
  end
end
