class CreateCollectionTags < ActiveRecord::Migration
  def change
    create_table :collection_tags do |t|
      t.belongs_to :collection
      t.belongs_to :tag
      t.timestamps
    end
  end
end
