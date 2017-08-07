require 'RMagick'
require 'pry'
require 'mini_magick'

Dir.glob('vendor/testing_images/*.{jpg}') do |file|
  image = Magick::Image.read(file)[0]
  image.colorspace = Magick::CMYKColorspace
  image.add_profile('vendor/color_profiles/PSO_Coated_300_NPscreen_ISO12647_eci.icc')
  image.write 'vendor/color_profile_test/' + File.basename(file, '.icc')
end

# Dir.glob('vendor/color_profiles/*.{icc}') do |file|
#   # RMagick
#   image = Magick::Image.read('vendor/testing_images/cmyk_color_block.jpg')[0]
#   image.colorspace =  Magick::CMYKColorspace
#   image.add_profile file
#
#   # image = MiniMagick::Image.open('vendor/testing_images/gradient.jpg')
#   # image.combine_options do |c|
#   #   c.colorspace 'cmyk'
#   #   c.profile file
#   # end
#   image.write 'vendor/color_profile_test/color_block/' + File.basename(file, '.icc') + '.jpg'
# end
