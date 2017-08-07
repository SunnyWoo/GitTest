class ChangeValueFromStringToTextInSiteSettings < ActiveRecord::Migration
  def change
    change_column :site_settings, :value, :text
  end
end
