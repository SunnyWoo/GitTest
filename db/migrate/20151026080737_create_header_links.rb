class CreateHeaderLinks < ActiveRecord::Migration
  def change
    create_table :header_links do |t|
      t.integer :parent_id
      t.string :href
      t.string :link_type
      t.integer :spec_id
      t.integer :position
      t.boolean :blank, null: false, default: false
      t.boolean :dropdown, null: false, default: false

      t.timestamps
    end
    HeaderLink.create_translation_table! title: :string
  end
end
