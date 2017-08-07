class ChangeHomeSlideColumn < ActiveRecord::Migration
  def change
    add_column :home_slides, :desc, :hstore
  end
end
