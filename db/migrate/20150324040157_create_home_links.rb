class CreateHomeLinks < ActiveRecord::Migration
  def up
    create_table :home_links do |t|
      t.string :href
      t.integer :position
      t.timestamps
    end
    HomeLink.create_translation_table! name: :string
  end

  def down
    drop_table :home_links
    HomeLink.drop_translation_table!
  end
end
