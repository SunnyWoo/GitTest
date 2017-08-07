class CreateTags < ActiveRecord::Migration
  def up
    create_table :tags do |t|
      t.timestamps
    end

    Tag.create_translation_table!(text: :string)
  end

  def down
    Tag.drop_translation_table!

    drop_table :tags
  end

  class Tag < ActiveRecord::Base
    translates :text, fallbacks_for_empty_translations: true
  end
end
