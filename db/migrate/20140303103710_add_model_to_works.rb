class AddModelToWorks < ActiveRecord::Migration
  def change
    add_column :works, :model, :string
  end
end
