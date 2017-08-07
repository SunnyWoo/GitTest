class CreateHomeSlideTranslationTable < ActiveRecord::Migration
  def up
    HomeSlide.create_translation_table!({
      title: :string
    }, {
      migrate_data: true
    })
  end

  def down
    HomeSlide.drop_translation_table! migrate_data: true
  end
end
