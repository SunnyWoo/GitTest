class MigrateHomeBlockItemImageToTranslations < ActiveRecord::Migration
  def change
    HomeBlockItem.find_each do |item|
      t = item.translations.find_by(locale: :en)
      t.update remote_pic_url: item.image.url unless t.nil?
    end
  end
end
