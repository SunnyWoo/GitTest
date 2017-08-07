class CreateEmailBanners < ActiveRecord::Migration
  def change
    create_table :email_banners do |t|
      t.string   :name
      t.string   :file
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean  :is_default, default: false
      t.timestamps
    end
  end
end
