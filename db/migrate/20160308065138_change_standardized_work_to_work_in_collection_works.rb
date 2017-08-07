class ChangeStandardizedWorkToWorkInCollectionWorks < ActiveRecord::Migration
  def change
    rename_column :collection_works, :standardized_work_id, :work_id
    add_column :collection_works, :work_type, :string
    add_column :collection_works, :position, :integer

    CollectionWork.destroy_all
  end
end
