class CreateBdeventWorks < ActiveRecord::Migration
  def change
    create_table :bdevent_works do |t|
      t.belongs_to :bdevent, index: true
      t.belongs_to :work, polymorphic: true, index: true
      t.json :info, default: {}, null: false
      t.string :image
      t.integer :position
      t.timestamps
    end
  end
end
