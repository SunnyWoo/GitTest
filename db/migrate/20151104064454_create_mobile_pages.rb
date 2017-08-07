class CreateMobilePages < ActiveRecord::Migration
  def change
    create_table :mobile_pages do |t|
      t.string :key
      t.string :title
      t.datetime :begin_at
      t.datetime :close_at
      t.boolean :is_enabled, default: false
      t.json :contents, default: {}
      t.timestamps
    end
  end
end
