class ExtractFactory < ActiveRecord::Migration
  def up
    rename_table :factories, :factory_members
    add_column :factory_members, :factory_id, :integer
    add_index :factory_members, :factory_id

    create_table :factories do |t|
      t.string 'code'
      t.string 'name'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
    add_index :factories, :code, unique: true

    execute <<-SQL
      INSERT INTO factories (id, code, name, created_at, updated_at)
      SELECT id, username, username, created_at, updated_at
      FROM factory_members;
    SQL
    execute <<-SQL
      UPDATE factory_members SET factory_id = id;
    SQL
  end

  def down
    drop_table :factories
    remove_column :factory_members, :factory_id
    rename_table :factory_members, :factories
  end
end
