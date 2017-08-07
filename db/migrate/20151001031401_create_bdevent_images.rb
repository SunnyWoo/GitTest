class CreateBdeventImages < ActiveRecord::Migration
  def change
    create_table :bdevent_images do |t|
      t.integer :bdevent_id
      t.string :locale
      t.string :file
      t.timestamps
      t.timestamps
    end
    add_index :bdevent_images, :bdevent_id
  end
end
