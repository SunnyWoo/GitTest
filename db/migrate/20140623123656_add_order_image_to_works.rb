class AddOrderImageToWorks < ActiveRecord::Migration
  def change
    add_column :works, :order_image, :string
  end
end
