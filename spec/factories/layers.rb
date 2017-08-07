# == Schema Information
#
# Table name: layers
#
#  id                         :integer          not null, primary key
#  work_id                    :integer
#  orientation                :float            default(0.0)
#  scale_x                    :float            default(1.0)
#  scale_y                    :float            default(1.0)
#  color                      :string(255)
#  transparent                :float            default(1.0)
#  font_name                  :string(255)
#  font_text                  :text
#  image                      :string(255)
#  material_name              :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  layer_type                 :integer
#  layer_no                   :string(255)
#  position_x                 :float            default(0.0)
#  position_y                 :float            default(0.0)
#  text_spacing_x             :integer
#  text_spacing_y             :integer
#  text_alignment             :string(255)
#  filter_type                :integer
#  position                   :integer
#  filter                     :string(255)      default("0")
#  filtered_image             :string(255)
#  uuid                       :string(255)
#  image_meta                 :text
#  disabled                   :boolean          default(FALSE), not null
#  attached_image_id          :integer
#  attached_filtered_image_id :integer
#  mask_id                    :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl
include ActionDispatch::TestProcess

FactoryGirl.define do
  test_jpg = fixture_file_upload('spec/photos/test.jpg', 'image/jpeg')

  factory :layer do
    work { create :work }
    material_name 'layer name'
    orientation Random.rand(0.0..360.0)
    scale_x Random.rand(0.0..10.0)
    scale_y Random.rand(0.0..10.0)
    color 'black'
    transparent Random.rand(0.0..10.0)
    font_name 'font_name'
    font_text 'font_text'
    image { test_jpg }
    filtered_image { test_jpg }
    layer_type :photo
    sequence(:layer_no) { |n| "no#{n}" }
    sequence(:position) { |n| n }
    position_x Random.rand(0.0..1000.0)
    position_y Random.rand(0.0..1000.0)
    text_spacing_x Random.rand(0..10)
    text_spacing_y Random.rand(0..10)
    text_alignment Random.rand(0..10)
    filter_type Random.rand(0..100)
  end
end
