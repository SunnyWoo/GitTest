class AddFinshedToWorks < ActiveRecord::Migration
  def change
    add_column :works, :finished, :boolean, default: false
  end
end
