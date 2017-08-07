class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.belongs_to :work, index: true
      t.belongs_to :tag, index: true

      t.timestamps
    end
  end
end
