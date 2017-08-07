class AddKeyToPreviewComposers < ActiveRecord::Migration
  def change
    add_column :preview_composers, :key, :string
    add_column :preview_composers, :available, :boolean, default: false, null: false

    add_index :preview_composers, [:spec_id, :key]
  end
end
