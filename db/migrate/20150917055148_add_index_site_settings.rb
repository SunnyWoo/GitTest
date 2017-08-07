class AddIndexSiteSettings < ActiveRecord::Migration
  def change
    add_index :site_settings, :key, unique: true
  end
end
