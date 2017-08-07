class CreateMobileComponents < ActiveRecord::Migration
  def change
    create_table :mobile_components do |t|
      t.belongs_to :mobile_page, index: true
      t.string :key
      t.integer :parent_id
      t.integer :position
      t.string :image
      t.json :contents, default: {}
      t.timestamps
    end
    add_index :mobile_components, :parent_id
  end
end
