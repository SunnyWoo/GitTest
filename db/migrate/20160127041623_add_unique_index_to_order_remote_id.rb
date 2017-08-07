class AddUniqueIndexToOrderRemoteId < ActiveRecord::Migration
  def change
    add_index :orders, %i(remote_id), unique: true
  end
end
