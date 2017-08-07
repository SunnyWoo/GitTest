class ChangeWorkToTaggableInTaggings < ActiveRecord::Migration
  def change
    rename_column :taggings, :work_id, :taggable_id
    rename_column :taggings, :work_type, :taggable_type
  end
end
