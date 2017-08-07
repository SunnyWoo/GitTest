class CreateHomeSlides < ActiveRecord::Migration
  def change
    create_table :home_slides do |t|
      t.string :slide
      t.boolean :is_enabled, default: true
      t.timestamps
    end
  end
end
