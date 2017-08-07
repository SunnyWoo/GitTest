class AddFeatureToWorks < ActiveRecord::Migration
  def change
    add_column :works, :feature, :boolean, default: false
  end
end
