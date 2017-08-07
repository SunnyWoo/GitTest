class CreateWorkOrderRelationships < ActiveRecord::Migration
  def change
    create_table :work_order_relationships do |t|
      t.belongs_to :work, index: true
      t.belongs_to :order, index: true

      t.timestamps
    end
  end
end
