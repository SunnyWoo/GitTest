class CreateHeaderLinkTags < ActiveRecord::Migration
  def change
    create_table :header_link_tags do |t|
      t.integer :header_link_id
      t.string :style
      t.integer :position

      t.timestamps
    end
    HeaderLinkTag.create_translation_table! title: :string
  end
end
