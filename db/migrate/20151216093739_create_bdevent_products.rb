class CreateBdeventProducts < ActiveRecord::Migration
  def change
    create_table :bdevent_products do |t|
      t.belongs_to :bdevent, index: true
      t.belongs_to :product, class_name: 'ProductModel', index: true
      t.string :image
      t.json :info, default: {}, null: false
      t.integer :position
      t.timestamps
    end
  end
end
