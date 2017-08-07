class AddMobileToUser < ActiveRecord::Migration
  def change
    add_column :users, :mobile, :string
    add_index :users, :mobile
  end
end
