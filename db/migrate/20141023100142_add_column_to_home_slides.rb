class AddColumnToHomeSlides < ActiveRecord::Migration
  def change
    add_column :home_slides, :title, :text
    add_column :home_slides, :link, :string
    add_column :home_slides, :template, :integer, default: 0
  end
end
