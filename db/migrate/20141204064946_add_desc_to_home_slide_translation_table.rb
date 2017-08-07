class AddDescToHomeSlideTranslationTable < ActiveRecord::Migration
  def up
    HomeSlide.add_translation_fields! slide: :string
  end

  def down
    remove_column :home_slide_translations, :slide, :string
  end
end
