class AddBackgroundToHomeSlides < ActiveRecord::Migration
  def change
    add_column :home_slides, :background, :string
  end
end
