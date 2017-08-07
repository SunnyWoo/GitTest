class AddColorizableToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :colorizable, :boolean, null: false, default: false
  end
end
