# == Schema Information
#
# Table name: work_specs
#
#  id                                        :integer          not null, primary key
#  model_id                                  :integer
#  name                                      :string(255)
#  description                               :text
#  width                                     :float
#  height                                    :float
#  dpi                                       :integer          default(300)
#  created_at                                :datetime
#  updated_at                                :datetime
#  background_image                          :string(255)
#  overlay_image                             :string(255)
#  shape                                     :string(255)
#  alignment_points                          :string(255)
#  padding_top                               :decimal(8, 2)    default(0.0), not null
#  padding_right                             :decimal(8, 2)    default(0.0), not null
#  padding_bottom                            :decimal(8, 2)    default(0.0), not null
#  padding_left                              :decimal(8, 2)    default(0.0), not null
#  background_color                          :string(255)      default("white"), not null
#  variant_id                                :integer
#  dir_name                                  :string
#  placeholder_image                         :string
#  enable_white                              :boolean          default(FALSE)
#  auto_imposite                             :boolean          default(FALSE)
#  watermark                                 :string
#  print_image_mask                          :string
#  enable_composite_with_horizontal_rotation :boolean          default(FALSE)
#  create_order_image_by_cover_image         :boolean          default(FALSE)
#  enable_back_image                         :boolean          default(FALSE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  test_jpg = fixture_file_upload('spec/photos/test.jpg', 'image/jpeg')

  factory :work_spec do
    variant { create(:variant) }
    sequence(:name) { |n| "cover-#{n}" }
    description { "description for #{name}" }
    width 1.5
    height 1.5
    dpi 300
    background_image { test_jpg }
    overlay_image { test_jpg }
    shape 'rectangle'
    alignment_points 'none'
    placeholder_image { test_jpg }
  end
end
