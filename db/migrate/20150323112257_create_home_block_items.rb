class CreateHomeBlockItems < ActiveRecord::Migration
  def up
    create_table :home_block_items do |t|
      t.belongs_to :block, index: true
      t.string :image
      t.string :href
      t.json :image_meta
      t.integer :position

      t.timestamps
    end

    HomeBlockItem.create_translation_table!(title: :string, subtitle: :string)
  end

  def down
    HomeBlockItem.drop_translation_table!

    drop_table :home_block_items
  end

  class HomeBlockItem < ActiveRecord::Base
    translates :title, :subtitle
  end
end
