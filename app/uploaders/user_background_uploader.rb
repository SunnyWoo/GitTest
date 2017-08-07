# encoding: utf-8

class UserBackgroundUploader < DefaultWithMetaUploader
  version :s35 do
    process resize_to_fill: [35, 35]
  end

  version :s154 do
    process resize_to_fill: [154, 154]
  end

  def default_url
    ActionController::Base.helpers.asset_path('my_gallery/img_gallery_kv-2.png')
  end
end
