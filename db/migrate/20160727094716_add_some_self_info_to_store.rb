class AddSomeSelfInfoToStore < ActiveRecord::Migration
  def change
    add_column :stores, :title, :string
    add_column :stores, :description, :text
    add_column :stores, :avatar, :string
  end
end
