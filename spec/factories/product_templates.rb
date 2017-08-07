# == Schema Information
#
# Table name: product_templates
#
#  id                    :integer          not null, primary key
#  product_model_id      :integer
#  store_id              :integer
#  price_tier_id         :integer
#  name                  :string(255)
#  placeholder_image     :string(255)
#  template_image        :string(255)
#  template_type         :integer
#  aasm_state            :string(255)
#  settings              :json
#  created_at            :datetime
#  updated_at            :datetime
#  image_meta            :json
#  works_count           :integer          default(0)
#  archived_works_count  :integer          default(0)
#  deleted_at            :datetime
#  bought_count          :integer          default(0)
#  special_price_tier_id :integer
#  description           :text
#

FactoryGirl.define do
  factory :product_template do
    product { create :mug_product_model }
    store { create :store }
    name 'Darth Vadar Version'

    trait :text_only do
      template_type 'text_only'
      settings do
        {
          font_name: 'billy',
          max_font_size: 16,
          min_font_size: 12,
          position_x: 0,
          position_y: 0,
          rotation: 0,
          color: '#170810'
        }
      end
    end

    trait :photo_only do
      template_type 'photo_only'
    end

    trait :text_and_photo do
      template_type 'text_and_photo'
      settings do
        {
          font_name: 'billy',
          max_font_size: 16,
          min_font_size: 12,
          position_x: 0,
          position_y: 0,
          rotation: 0,
          color: '#170810'
        }
      end
    end
  end
end
