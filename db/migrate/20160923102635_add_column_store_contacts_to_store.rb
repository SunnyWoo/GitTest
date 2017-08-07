class AddColumnStoreContactsToStore < ActiveRecord::Migration
  def change
    add_column :stores, :contact_info, :hstore
  end
end
