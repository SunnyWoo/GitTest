class TestForAutoConvertOldHomeslideSlideToTranslationTable < ActiveRecord::Migration
  class OldSlideUploader < ::DefaultUploader
    def store_dir
      "uploads/home_slide/#{mounted_as}/#{model.id}"
    end
  end

  class NewSlideUploader < ::DefaultUploader
    def store_dir
      "uploads/home_slide/translation/#{mounted_as}/#{model.id}"
    end
    version :s1600 do
      process resize_to_fill: [1600, 784]
    end
  end

  class OldHomeSlide < ActiveRecord::Base
    self.table_name = :home_slides
    mount_uploader :slide, OldSlideUploader
  end

  class NewHomeSlide < ActiveRecord::Base
    self.table_name = :home_slides
    translates :slide, :title
    globalize_accessors
    accepts_nested_attributes_for :translations
    Translation.mount_uploader :slide, NewSlideUploader
  end

  def up
    old_slide = OldHomeSlide.all.map do |hs|
                  { id: hs.id, url: hs.slide.url }
                end
    old_slide.each do |old|
      dad = NewHomeSlide.find old[:id]
      baby = dad.translations.find_by(locale: :en) || dad.translations.new(locale: :en)
      baby.remote_slide_url = old[:url]
      baby.save
    end

  end

  def down
    NewHomeSlide.all.each do |home_slide|
      home_slide.translations.find_by(locale: :en).try(:destroy)
    end
  end

end
