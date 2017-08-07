class ChangeWorkColumnImpressionistCountWithSettingDefaultValue < ActiveRecord::Migration
  def change
    change_column :works, :impressions_count, :integer, default: 0
  end
end
