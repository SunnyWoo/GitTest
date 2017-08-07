class AddPlatformsToBanners < ActiveRecord::Migration
  PLATFORMS = %w(iOS Android)

  def up
    add_column :banners, :platforms, :string, array: true, default: []

    Banner.find_each do |banner|
      banner.update(platforms: PLATFORMS)
    end
  end

  def down
    remove_column :banners, :platforms
  end

  class Banner < ActiveRecord::Base
  end
end
