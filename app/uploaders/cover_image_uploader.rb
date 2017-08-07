class CoverImageUploader < DefaultWithMetaUploader
  optimize!

  def shop
    on_the_fly_process(resize_to_limit: [nil, 750])
  end

  version :crop do
    process :crop
  end

  after :store, :enqueue_build_previews_by_cover_image

  def enqueue_build_previews_by_cover_image(file)
    model.cover_image_stored!
  end
end
