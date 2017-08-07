class AddProfileToUser < ActiveRecord::Migration
  def change
    add_column :users, :profile, :hstore
    add_column :users, :gender, :integer
  end
end
