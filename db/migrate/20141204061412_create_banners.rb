class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.string :name
      t.string :image
      t.text :image_meta
      t.date :begin_on
      t.date :end_on
      t.string :countries, array: true, default: []

      t.timestamps
    end
  end
end
