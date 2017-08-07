class AddWorkTypeToTaggings < ActiveRecord::Migration
  def change
    add_column :taggings, :work_type, :string
    add_index :taggings, :work_type
    add_index :taggings, [:work_id, :work_type]

    Tagging.update_all(work_type: 'Work')
  end

  class Tagging < ActiveRecord::Base
  end
end
