return if Rails.env.test?

require 'seed-fu'
image_model_path = 'vendor/assets/images/editor/model'

work_specs = [
  {
    model_key: 'samsung_s4_cases',
    name: 'case',
    width: 90.23,
    height: 142.66,
    dpi: 300,
    background_image_path: "#{image_model_path}/samsung4_alpha.png",
    overlay_image_path: "#{image_model_path}/samsung4_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'samsung_note3_cases',
    name: 'case',
    width: 99.45,
    height: 156.76,
    dpi: 300,
    background_image_path: "#{image_model_path}/samsungnote3_alpha.png",
    overlay_image_path: "#{image_model_path}/samsungnote3_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'samsung_s5_cases',
    name: 'case',
    width: 94.7,
    height: 150.07,
    dpi: 300,
    background_image_path: "#{image_model_path}/samsung5_alpha.png",
    overlay_image_path: "#{image_model_path}/samsung5_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'ipad_air_covers',
    name: 'iPad Air Covers',
    width: 362.0,
    height: 246.0,
    dpi: 300,
    background_image_path: "#{image_model_path}/ipadaircover_alpha.png",
    overlay_image_path: "#{image_model_path}/ipadaircover_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'ipad_mini_covers',
    name: 'iPad mini Covers',
    width: 295.0,
    height: 209.5,
    dpi: 300,
    background_image_path: "#{image_model_path}/ipadminicover_alpha.png",
    overlay_image_path: "#{image_model_path}/ipadminicover_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'mugs',
    name: 'Mugs',
    width: 210.0,
    height: 85.0,
    dpi: 300,
    background_image_path: "#{image_model_path}/mug_alpha.png",
    overlay_image_path: "#{image_model_path}/mug_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'easycard_smartcards',
    name: 'EasyCard',
    width: 89.65,
    height: 58.0,
    dpi: 300,
    background_image_path: "#{image_model_path}/easycard_alpha.png",
    overlay_image_path: "#{image_model_path}/easycard_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'wood_white_clocks',
    name: 'Clock',
    width: 291.0,
    height: 291.0,
    dpi: 300,
    background_image_path: "#{image_model_path}/clock_alpha.png",
    overlay_image_path: "#{image_model_path}/clock_fullsize.png",
    shape: 'ellipse',
    alignment_points: 'none'
  },
  {
    model_key: 'iphone_6plus_cases',
    name: 'cover',
    width: 99.0,
    height: 178.0,
    dpi: 300,
    background_image_path: "#{image_model_path}/iphone6plus_alpha.png",
    overlay_image_path: "#{image_model_path}/iphone6plus_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'iphone_6_cases',
    name: 'cover',
    width: 87.0,
    height: 150.0,
    dpi: 300,
    background_image_path: "#{image_model_path}/iphone6_alpha.png",
    overlay_image_path: "#{image_model_path}/iphone6_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'ipad_mini_cases',
    name: 'case',
    width: 158.0,
    height: 222.0,
    dpi: 300,
    background_image_path: "#{image_model_path}/ipadmini_alpha.png",
    overlay_image_path: "#{image_model_path}/ipadmini_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'iphone_4_cases',
    name: 'case',
    width: 80.0,
    height: 130.0,
    dpi: 300,
    background_image_path: "#{image_model_path}/i4s&4_alpha.png",
    overlay_image_path: "#{image_model_path}/i4s&4_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'iphone_5_cases',
    name: 'case',
    width: 75.0,
    height: 135.0,
    dpi: 300,
    background_image_path: "#{image_model_path}/i5s&5_alpha.png",
    overlay_image_path: "#{image_model_path}/i5s&5_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  },
  {
    model_key: 'ipad_air2_covers',
    name: 'case',
    width: 352.0,
    height: 247.0,
    dpi: 300,
    background_image_path: "#{image_model_path}/ipadair2cover_alpha.png",
    overlay_image_path: "#{image_model_path}/ipadair2cover_fullsize.png",
    shape: 'rectangle',
    alignment_points: 'none'
  }
]

work_specs.each do |work_spec|
  WorkSpec.seed_once(:model_id) do |s|
    s.model_id = ProductModel.find_by(key: work_spec[:model_key]).id
    s.name = work_spec[:name]
    s.width = work_spec[:width]
    s.height = work_spec[:height]
    s.dpi = work_spec[:dpi]
    s.background_image = File.new(work_spec[:background_image_path]) if work_spec[:background_image_path]
    s.overlay_image = File.new(work_spec[:overlay_image_path]) if work_spec[:overlay_image_path]
    s.shape = work_spec[:shape]
    s.alignment_points = work_spec[:alignment_points]
  end
end

# Work & Artwork

model = ProductModel.find_by(key: 'iphone_5_cases')
spec = model.spec
designer = Designer.first
price_tier = PriceTier.find_by(tier: 32)

rows = {
  name: 'Seed Me',
  work_type: 'is_public',
  model_id: model.id,
  user_id: designer.id,
  user_type: 'Designer'
}

Artwork.seed_once(:name, rows)
artwork = Artwork.last
image_path = "#{Rails.root}/db/fixtures/images"
print_image_file = "#{image_path}/watermelon_print_image.jpg"
cover_image_file = "#{image_path}/watermelon.jpg"
order_image_file = "#{image_path}/watermelon_order_image.jpg"
print_image = ActionDispatch::Http::UploadedFile.new(
  filename: File.basename(print_image_file), tempfile: File.open(print_image_file)
)
cover_image = ActionDispatch::Http::UploadedFile.new(
  filename: File.basename(cover_image_file), tempfile: File.open(cover_image_file)
)

rows = {
  name: 'Seed Me',
  work_type: 'is_public',
  # artwork: artwork,
  # spec: spec,
  model: model,
  print_image: print_image,
  cover_image: cover_image,
  user_id: designer.id,
  user_type: 'Designer',
  price_tier: price_tier
}

Work.new(rows).tap do |work|
  work.save!
  work.build_layer(image: work.print_image)
  work.finish!
  work.previews.create(key: 'order-image', image: cover_image)
end unless Work.find_by(name: rows[:name])
