return if Rails.env.test?

require 'seed-fu'

front_back_image_path = 'vendor/assets/images/preview_composers/front_back'

PreviewComposer::FrontBack.seed_once(:model_id) do |s|
  s.model_id = ProductModel.find_by(key: 'samsung_s4_cases').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/samsung_s4_cases/case.png"), tempfile: File.open("#{front_back_image_path}/samsung_s4_cases/case.png"))
  s.left_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/samsung_s4_cases/left.png"), tempfile: File.open("#{front_back_image_path}/samsung_s4_cases/left.png"))
  s.right_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/samsung_s4_cases/right.png"), tempfile: File.open("#{front_back_image_path}/samsung_s4_cases/right.png"))
  s.left_mask_left = 10
  s.left_mask_top = 30
  s.left_mask_width = 368
  s.left_mask_height = 580
  s.right_mask_left = 248
  s.right_mask_top = 22
  s.right_mask_width = 376
  s.right_mask_height = 594
end

PreviewComposer::FrontBack.seed_once(:model_id) do |s|
  s.model_id = ProductModel.find_by(key: 'iphone_5_cases').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_5_cases/case.png"), tempfile: File.open("#{front_back_image_path}/iphone_5_cases/case.png"))
  s.left_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_5_cases/left.png"), tempfile: File.open("#{front_back_image_path}/iphone_5_cases/left.png"))
  s.right_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_5_cases/right.png"), tempfile: File.open("#{front_back_image_path}/iphone_5_cases/right.png"))
  s.left_mask_left = -2
  s.left_mask_top = -46
  s.left_mask_width = 396
  s.left_mask_height = 712
  s.right_mask_left = 288
  s.right_mask_top = -58
  s.right_mask_width = 408
  s.right_mask_height = 732
end

PreviewComposer::FrontBack.seed_once(:model_id) do |s|
  s.model_id = ProductModel.find_by(key: 'samsung_note3_cases').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/samsung_note3_cases/case.png"), tempfile: File.open("#{front_back_image_path}/samsung_note3_cases/case.png"))
  s.left_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/samsung_note3_cases/left.png"), tempfile: File.open("#{front_back_image_path}/samsung_note3_cases/left.png"))
  s.right_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/samsung_note3_cases/right.png"), tempfile: File.open("#{front_back_image_path}/samsung_note3_cases/right.png"))
  s.left_mask_left = 0
  s.left_mask_top = 20
  s.left_mask_width = 378
  s.left_mask_height = 596
  s.right_mask_left = 248
  s.right_mask_top = 10
  s.right_mask_width = 390
  s.right_mask_height = 614
end

PreviewComposer::FrontBack.seed_once(:model_id) do |s|
  s.model_id = ProductModel.find_by(key: 'samsung_s5_cases').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/samsung_s5_cases/case.png"), tempfile: File.open("#{front_back_image_path}/samsung_s5_cases/case.png"))
  s.left_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/samsung_s5_cases/left.png"), tempfile: File.open("#{front_back_image_path}/samsung_s5_cases/left.png"))
  s.right_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/samsung_s5_cases/right.png"), tempfile: File.open("#{front_back_image_path}/samsung_s5_cases/right.png"))
  s.left_mask_left = 0
  s.left_mask_top = 22
  s.left_mask_width = 374
  s.left_mask_height = 590
  s.right_mask_left = 260
  s.right_mask_top = 20
  s.right_mask_width = 378
  s.right_mask_height = 600
end

PreviewComposer::Simple.seed_once(:model_id, :key) do |s|
  s.model_id = ProductModel.find_by(key: 'ipad_air_covers').id
  s.key = 'backview'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_air_covers/backview_cover.png"), tempfile: File.open("#{front_back_image_path}/ipad_air_covers/backview_cover.png"))
  s.mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_air_covers/backview_alpha.png"), tempfile: File.open("#{front_back_image_path}/ipad_air_covers/backview_alpha.png"))
  s.mask_left = 116
  s.mask_top = 32
  s.mask_width = 842
  s.mask_height = 572
end
PreviewComposer::Simple.seed_once(:model_id, :key) do |s|
  s.model_id = ProductModel.find_by(key: 'ipad_air_covers').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_air_covers/frontview_cover.png"), tempfile: File.open("#{front_back_image_path}/ipad_air_covers/frontview_cover.png"))
  s.mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_air_covers/frontview_alpha.png"), tempfile: File.open("#{front_back_image_path}/ipad_air_covers/frontview_alpha.png"))
  s.mask_left = -314
  s.mask_top = 32
  s.mask_width = 842
  s.mask_height = 572
end


PreviewComposer::Simple.seed_once(:model_id, :key) do |s|
  s.model_id = ProductModel.find_by(key: 'ipad_mini_covers').id
  s.key = 'backview'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_mini_covers/backview_cover.png"), tempfile: File.open("#{front_back_image_path}/ipad_mini_covers/backview_cover.png"))
  s.mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_mini_covers/backview_alpha.png"), tempfile: File.open("#{front_back_image_path}/ipad_mini_covers/backview_alpha.png"))
  s.mask_left = 110
  s.mask_top = 26
  s.mask_width = 826
  s.mask_height = 588
end
PreviewComposer::Simple.seed_once(:model_id, :key) do |s|
  s.model_id = ProductModel.find_by(key: 'ipad_mini_covers').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_mini_covers/frontview_cover.png"), tempfile: File.open("#{front_back_image_path}/ipad_mini_covers/frontview_cover.png"))
  s.mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_mini_covers/frontview_alpha.png"), tempfile: File.open("#{front_back_image_path}/ipad_mini_covers/frontview_alpha.png"))
  s.mask_left = -296
  s.mask_top = 26
  s.mask_width = 826
  s.mask_height = 588
end

PreviewComposer::VerticalDisplace.seed_once(:model_id, :key) do |s|
  s.model_id = ProductModel.find_by(key: 'mugs').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/mugs/rightsideview_cover.png"), tempfile: File.open("#{front_back_image_path}/mugs/rightsideview_cover.png"))
  s.mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/mugs/rightsideview_gradient.png"), tempfile: File.open("#{front_back_image_path}/mugs/rightsideview_gradient.png"))
  s.mask_left = -260
  s.mask_top = 90
  s.mask_width = 722
  s.mask_height = 456
  s.mask_displace = 40
end
PreviewComposer::VerticalDisplace.seed_once(:model_id, :key) do |s|
  s.model_id = ProductModel.find_by(key: 'mugs').id
  s.key = 'leftview'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/mugs/leftsideview_cover.png"), tempfile: File.open("#{front_back_image_path}/mugs/leftsideview_cover.png"))
  s.mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/mugs/leftsideview_gradient.png"), tempfile: File.open("#{front_back_image_path}/mugs/leftsideview_gradient.png"))
  s.mask_left = 140
  s.mask_top = 90
  s.mask_width = 772
  s.mask_height = 456
  s.mask_displace = 40
end

PreviewComposer::Simple.seed_once(:model_id, :key) do |s|
  s.model_id = ProductModel.find_by(key: 'easycard_smartcards').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/easycard_smartcards/frontview_cover.png"), tempfile: File.open("#{front_back_image_path}/easycard_smartcards/frontview_cover.png"))
  s.mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/easycard_smartcards/frontview_alpha.png"), tempfile: File.open("#{front_back_image_path}/easycard_smartcards/frontview_alpha.png"))
  s.mask_left = 50
  s.mask_top = 154
  s.mask_width = 540
  s.mask_height = 350
end

PreviewComposer::Simple.seed_once(:model_id, :key) do |s|
  s.model_id = ProductModel.find_by(key: 'wood_white_clocks').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/wood_white_clocks/frontview_cover.png"), tempfile: File.open("#{front_back_image_path}/wood_white_clocks/frontview_cover.png"))
  s.mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/wood_white_clocks/frontview_alpha.png"), tempfile: File.open("#{front_back_image_path}/wood_white_clocks/frontview_alpha.png"))
  s.mask_left = 76
  s.mask_top = 72
  s.mask_width = 486
  s.mask_height = 486
end

PreviewComposer::FrontBack.seed_once(:model_id) do |s|
  s.model_id = ProductModel.find_by(key: 'iphone_6plus_cases').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_6plus_cases/case.png"), tempfile: File.open("#{front_back_image_path}/iphone_6plus_cases/case.png"))
  s.left_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_6plus_cases/left.png"), tempfile: File.open("#{front_back_image_path}/iphone_6plus_cases/left.png"))
  s.right_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_6plus_cases/right.png"), tempfile: File.open("#{front_back_image_path}/iphone_6plus_cases/right.png"))
  s.left_mask_left = 6
  s.left_mask_top = -12
  s.left_mask_width = 370
  s.left_mask_height = 668
  s.right_mask_left = 248
  s.right_mask_top = -24
  s.right_mask_width = 384
  s.right_mask_height = 692
end

PreviewComposer::FrontBack.seed_once(:model_id) do |s|
  s.model_id = ProductModel.find_by(key: 'iphone_6_cases').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_6_cases/case.png"), tempfile: File.open("#{front_back_image_path}/iphone_6_cases/case.png"))
  s.left_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_6_cases/left.png"), tempfile: File.open("#{front_back_image_path}/iphone_6_cases/left.png"))
  s.right_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_6_cases/right.png"), tempfile: File.open("#{front_back_image_path}/iphone_6_cases/right.png"))
  s.left_mask_left = 16
  s.left_mask_top = 8
  s.left_mask_width = 366
  s.left_mask_height = 628
  s.right_mask_left = 248
  s.right_mask_top = -4
  s.right_mask_width = 378
  s.right_mask_height = 650
end
PreviewComposer::VerticalDisplace.seed_once(:model_id, :key) do |s|
  s.model_id = ProductModel.find_by(key: 'iphone_6_cases').id
  s.key = 'r45'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_6_cases/rightsideview_cover.png"), tempfile: File.open("#{front_back_image_path}/iphone_6_cases/rightsideview_cover.png"))
  s.mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_6_cases/rightsideview_gradient.png"), tempfile: File.open("#{front_back_image_path}/iphone_6_cases/rightsideview_gradient.png"))
  s.mask_left = 174
  s.mask_top = 23
  s.mask_width = 260
  s.mask_height = 590
  s.mask_displace = 20
end

PreviewComposer::FrontBack.seed_once(:model_id) do |s|
  s.model_id = ProductModel.find_by(key: 'ipad_mini_cases').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_mini_cases/case.png"), tempfile: File.open("#{front_back_image_path}/ipad_mini_cases/case.png"))
  s.left_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_mini_cases/left.png"), tempfile: File.open("#{front_back_image_path}/ipad_mini_cases/left.png"))
  s.right_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/ipad_mini_cases/right.png"), tempfile: File.open("#{front_back_image_path}/ipad_mini_cases/right.png"))
  s.left_mask_left = -12
  s.left_mask_top = 16
  s.left_mask_width = 438
  s.left_mask_height = 612
  s.right_mask_left = 200
  s.right_mask_top = 8
  s.right_mask_width = 448
  s.right_mask_height = 626
end

PreviewComposer::FrontBack.seed_once(:model_id) do |s|
  s.model_id = ProductModel.find_by(key: 'iphone_4_cases').id
  s.key = 'order-image'
  s.available = true
  s.background_width = 640
  s.background_height = 640
  s.case_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_4_cases/case.png"), tempfile: File.open("#{front_back_image_path}/iphone_4_cases/case.png"))
  s.left_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_4_cases/left.png"), tempfile: File.open("#{front_back_image_path}/iphone_4_cases/left.png"))
  s.right_mask_file = ActionDispatch::Http::UploadedFile.new(filename: File.basename("#{front_back_image_path}/iphone_4_cases/right.png"), tempfile: File.open("#{front_back_image_path}/iphone_4_cases/right.png"))
  s.left_mask_left = -10
  s.left_mask_top = -10
  s.left_mask_width = 416
  s.left_mask_height = 676
  s.right_mask_left = 234
  s.right_mask_top = -20
  s.right_mask_width = 426
  s.right_mask_height = 694
end
