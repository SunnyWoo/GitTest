class CreateCollectionWorks < ActiveRecord::Migration
  def change
    create_table :collection_works do |t|
      t.integer :collection_id
      t.integer :standardized_work_id

      t.timestamps
    end
  end
end
