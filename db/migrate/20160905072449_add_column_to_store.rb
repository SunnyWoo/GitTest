class AddColumnToStore < ActiveRecord::Migration
  def change
    add_column :stores, :tap_settings, :json
  end
end
