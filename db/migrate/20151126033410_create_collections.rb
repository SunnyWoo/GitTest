class CreateCollections < ActiveRecord::Migration
  def up
    create_table :collections do |t|
      t.string :name
      t.timestamps
    end

    Collection.create_translation_table!(text: :string)
  end

  def down
    Collection.drop_translation_table!

    drop_table :collections
  end

  class Collection < ActiveRecord::Base
    translates :text, fallbacks_for_empty_translations: true
  end
end
