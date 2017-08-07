# == Schema Information
#
# Table name: archived_layers
#
#  id             :integer          not null, primary key
#  work_id        :integer
#  layer_type     :string(255)
#  orientation    :float            default(0.0)
#  scale_x        :float            default(1.0)
#  scale_y        :float            default(1.0)
#  color          :string(255)
#  transparent    :float            default(1.0)
#  font_name      :string(255)
#  font_text      :text
#  image          :string(255)
#  filter         :string(255)
#  filtered_image :string(255)
#  material_name  :string(255)
#  position_x     :float            default(0.0)
#  position_y     :float            default(0.0)
#  text_spacing_x :float            default(0.0)
#  text_spacing_y :float            default(0.0)
#  text_alignment :string(255)
#  position       :integer
#  image_meta     :json
#  created_at     :datetime
#  updated_at     :datetime
#  disabled       :boolean          default(FALSE), not null
#  mask_id        :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl
include ActionDispatch::TestProcess

FactoryGirl.define do
  test_jpg = fixture_file_upload('spec/photos/test.jpg', 'image/jpeg')

  factory :archived_layer do
    work { create :archived_work }
    sequence(:material_name) { |n| "layer_name_#{n}" }
    orientation Random.rand(0.0..360.0)
    scale_x Random.rand(0.0..10.0)
    scale_y Random.rand(0.0..10.0)
    color 'black'
    transparent Random.rand(0.0..10.0)
    font_name 'font_name'
    font_text 'font_text'
    image { test_jpg }
    filtered_image { test_jpg }
    layer_type 'photo'
    sequence(:position) { |n| n }
    position_x Random.rand(0.0..1000.0)
    position_y Random.rand(0.0..1000.0)
    text_spacing_x Random.rand(0..10)
    text_spacing_y Random.rand(0..10)
    text_alignment Random.rand(0..10)

    trait :mask do
      layer_type 'mask'

      after(:build) do |layer|
        create(:mask, material_name: layer.material_name)
      end
    end
  end
end
