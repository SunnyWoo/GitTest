# encoding: utf-8

class DesignerAvatarUploader < DefaultWithMetaUploader
  def s35
    on_the_fly_process resize_to_fill: [35, 35]
  end

  def s154
    on_the_fly_process resize_to_fill: [154, 154]
  end

  def default_url
    ActionController::Base.helpers.asset_path('img_fbdefault.png')
  end
end
