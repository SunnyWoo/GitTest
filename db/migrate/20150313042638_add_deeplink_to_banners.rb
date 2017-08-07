class AddDeeplinkToBanners < ActiveRecord::Migration
  def change
    add_column :banners, :deeplink, :string
  end
end
