class CreateWorkSets < ActiveRecord::Migration
  def change
    create_table :work_sets do |t|
      t.belongs_to :designer, index: true
      t.belongs_to :spec, index: true
      t.integer :artwork_ids, array: true, default: []
      t.timestamps
    end
  end
end
