class CreateMobilePagePreviews < ActiveRecord::Migration
  def change
    create_table :mobile_page_previews do |t|
      t.integer :mobile_page_id
      t.string :key
      t.string :title
      t.string :country_code
      t.datetime :begin_at
      t.datetime :close_at
      t.integer :page_type
      t.json :contents, default: {}
      t.boolean :is_enabled
      t.timestamps null: false
    end
  end
end
