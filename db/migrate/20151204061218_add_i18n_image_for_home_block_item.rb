class AddI18nImageForHomeBlockItem < ActiveRecord::Migration
  def up
    HomeBlockItem.add_translation_fields! pic: :string
  end

  def down
    remove_column :home_block_item_translations, :pic
  end
end
