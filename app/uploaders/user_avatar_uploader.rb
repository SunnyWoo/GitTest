# encoding: utf-8

class UserAvatarUploader < DefaultUploader
  version :s35 do
    process resize_to_fill: [35, 35]
  end

  version :s114 do
    process resize_to_fill: [114, 114]
  end

  version :s154 do
    process resize_to_fill: [154, 154]
  end

  def default_url
    ActionController::Base.helpers.asset_path('img_fbdefault.png')
  end
end
