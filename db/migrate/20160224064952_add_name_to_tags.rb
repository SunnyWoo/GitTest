class AddNameToTags < ActiveRecord::Migration
  def change
    add_column :tags, :name, :string

    Tag.find_each do |tag|
      tag.update_column(:name, tag.text_en)
    end

    add_index :tags, :name, unique: true
  end
end
