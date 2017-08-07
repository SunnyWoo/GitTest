# encoding: utf-8

class SlideUploader < DefaultUploader
  process :interlace

  version :s1600 do
    process resize_to_fill: [1600, 784]
  end
end
