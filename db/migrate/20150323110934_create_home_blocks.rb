class CreateHomeBlocks < ActiveRecord::Migration
  def up
    create_table :home_blocks do |t|
      t.string :template
      t.integer :position

      t.timestamps
    end

    HomeBlock.create_translation_table!(title: :string)
  end

  def down
    HomeBlock.drop_translation_table!

    drop_table :home_blocks
  end

  class HomeBlock < ActiveRecord::Base
    translates :title
  end
end
