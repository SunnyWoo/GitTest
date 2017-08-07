# encoding: utf-8

class MobileUiUploader < DefaultUploader
  version :x_2 do
    process resize_by_percentage: "66%"
  end

  version :x_1 do
    process resize_by_percentage: "33%"
  end

  def resize_by_percentage(percentage)
    manipulate! do |img|
      img.resize(percentage)
      img
    end
  end
end
