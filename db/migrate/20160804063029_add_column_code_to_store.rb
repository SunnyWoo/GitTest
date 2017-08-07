class AddColumnCodeToStore < ActiveRecord::Migration
  def change
    add_column :stores, :code, :string
    Store.find_each(&:save)
  end
end
