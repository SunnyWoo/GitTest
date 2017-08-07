class AddColumnSetToHomeSlide < ActiveRecord::Migration
  def change
    add_column :home_slides, :set, :string
  end
end
