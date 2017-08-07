class AddPrintImageToWorks < ActiveRecord::Migration
  def change
    add_column :works, :print_image, :string
  end
end
