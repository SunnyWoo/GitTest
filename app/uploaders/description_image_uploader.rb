# encoding: utf-8
class DescriptionImageUploader < DefaultUploader
  attr_reader :width, :height
  before :cache, :capture_size

  def x1
    on_the_fly_process resize_to_limit: [640, nil]
  end

  def x2
    on_the_fly_process resize_to_limit: [640, nil]
  end

  def capture_size(file)
    if version_name.blank?
      if file.path.nil?
        img = ::MiniMagick::Image.read(file.file)
        @width = img[:width]
        @height = img[:height]
      else
        @width, @height = `identify -format "%wx %h" #{file.path}`.split(/x/).map(&:to_i)
      end
    end
  end
end
