class DropFileGetways < ActiveRecord::Migration
  def up
    drop_table :file_getways
  end

  def down
    create_table :file_getways do |t|
      t.string  :type
      t.integer :factory_id
      t.hstore  :connect_info

      t.timestamps
    end
    add_index :file_getways, :factory_id\
  end
end
