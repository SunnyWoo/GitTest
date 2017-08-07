module EditorHelper
  def editor_font_list
    @@font_files ||= Dir['./vendor/assets/fonts/*']
    @@font_list = @@font_files.map { |file|
      %r{./vendor/(.*)}.match(file)[1].gsub('/editor', '')
    }

    @@font_list
  end

  def editor_font_name
    @@font_files ||= Dir['./vendor/assets/fonts/*']
    @@font_name ||= @@font_files.map { |file|
      %r{./vendor/assets/fonts/(.*)\..+$}.match(file)[1]
    }

    @@font_name
  end

  def editor_fonts
    FontService.instance.fonts
  end

  %w(line shape sticker texture typography frame).each do |attr|
    define_method "editor_#{attr}_list" do
      Dir["./vendor/assets/images/editor/#{attr}/*"].sort.map do |file|
        {
          file: image_url(%r{./vendor/assets/images/(.*)}.match(file)[1]),
          name: %r{./vendor/assets/images/editor/#{attr}/(.*)\..+$}.match(file)[1]
        }
      end
    end
  end

  # TODO: change model_name  => model_key
  def editor_model_background_path(work)
    case work.product_key
    when 'iphone_5_cases'
      image_path 'editor/model/i5s&5_fullsize.png'
    when 'iphone_4_cases'
      image_path 'editor/model/i4s&4_fullsize.png'
    when 'ipad_mini_cases'
      image_path 'editor/model/ipadmini_fullsize.png'
    when 'ipad_mini_covers'
      image_path 'editor/model/ipadminicover_fullsize.png'
    when 'ipad_air_cases'
      image_path 'editor/model/ipadaircover_fullsize.png'
    when 'iphone_6_cases'
      image_path 'editor/model/iphone6_fullsize.png'
    when 'iphone_6plus_cases'
      image_path 'editor/model/iphone6plus_fullsize.png'
    when 'clocks'
      image_path 'editor/model/clock_fullsize.png'
    when 'easycard_smartcards'
      image_path 'editor/model/easycard_fullsize.png'
    when 'mugs'
      image_path 'editor/model/mug_fullsize.png'
    else
      'Editor initial error!'
    end
  end

  def editor_model_init_shape_path(work)
    case work.product_key
    when 'iphone_5_cases'
      image_path 'editor/model/i5s&5_alpha.png'
    when 'iphone_4_cases'
      image_path 'editor/model/i4s&4_alpha.png'
    when 'ipad_mini_cases'
      image_path 'editor/model/ipadmini_alpha.png'
    when 'ipad_mini_covers'
      image_path 'editor/model/ipadminicover_alpha.png'
    when 'ipad_air_cases'
      image_path 'editor/model/ipadaircover_alpha.png'
    when 'iphone_6_cases'
      image_path 'editor/model/iphone6_alpha.png'
    when 'iphone_6plus_cases1'
      image_path 'editor/model/iphone6plus_alpha.png'
    when 'clocks'
      image_path 'editor/model/clock_alpha.png'
    when 'easycard_smartcards'
      image_path 'editor/model/easycard_alpha.png'
    when 'mugs'
      image_path 'editor/model/mug_alpha.png'
    else
      'Editor initial error!'
    end
  end
end
