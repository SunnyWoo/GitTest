# 這個工廠會建立各種 mini_magick 沒辦法直接建立出來的東西.
# 因為建立過程通常很髒, 所以藏起來統一放這裡.
# 所有方法都會回傳一個 MiniMagick::Image.
module ImageService::MiniMagick::ImageFactory
  DEFAULT_FONT_SIZE = 108 * 5

  FORMAT_TO_EXT = {
    'PNG32' => '.png',
    'JPEG' => '.jpg'
  }.freeze

  # 指定 size 建立空白圖檔
  def create_blank_image(width, height, color: 'white', format: 'PNG32')
    tempfile = Tempfile.new(['canvas', FORMAT_TO_EXT[format]])
    system "convert -size #{width}x#{height} xc:#{color} #{format}:#{tempfile.path}"
    MiniMagick::Image.open(tempfile.path)
  ensure
    tempfile.close
    tempfile.unlink
  end

  # 建立文字材質, 必定是透明背景以及白色文字
  def create_text_image(text, font_file, align: 'Left')
    gravity = case align.to_s
              when 'Left'   then 'West'
              when 'Center' then 'Center'
              when 'Right'  then 'East'
              else               'West'
              end
    text_image = Tempfile.new(['text_image', '.png'])
    padded_text = "\n#{text}\n"
    system "convert -background transparent \
                    -fill white \
                    -pointsize #{DEFAULT_FONT_SIZE} \
                    -font #{font_file.shellescape} \
                    -gravity #{gravity} \
                    label:#{padded_text.shellescape} \
                    #{text_image.path.shellescape}"
    MiniMagick::Image.open(text_image.path)
  ensure
    text_image.close
    text_image.unlink
  end

  def create_shape_image(width, height, ext: '.jpg', background_color: 'black', color: 'white', draw: nil)
    tempfile = Tempfile.new(['canvas', ext])
    system "convert -size #{width}x#{height} xc:#{background_color} -fill #{color} -draw '#{draw}' #{tempfile.path}"
    MiniMagick::Image.open(tempfile.path)
  ensure
    tempfile.close
    tempfile.unlink
  end
end
