class AddUuidToWorks < ActiveRecord::Migration
  def change
    add_column :works, :uuid, :string
    add_index :works, :uuid
  end
end
