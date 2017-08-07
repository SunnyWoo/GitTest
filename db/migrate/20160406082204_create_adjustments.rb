class CreateAdjustments < ActiveRecord::Migration
  def change
    create_table :adjustments do |t|
      t.belongs_to :order, index: true
      t.belongs_to :adjustable, polymorphic: true, index: true
      t.belongs_to :source, polymorphic: true, index: true
      t.float :value
      t.string :description
      t.timestamps
    end
  end
end
