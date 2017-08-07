# == Schema Information
#
# Table name: mobile_components
#
#  id             :integer          not null, primary key
#  mobile_page_id :integer
#  key            :string(255)
#  parent_id      :integer
#  position       :integer
#  image          :string(255)
#  contents       :json             default({})
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :sub_mobile_component do
    factory :sub_component_with_image do
      image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    end

    factory :kv_sub_component do
      contents { { link: 'test-commandp://home' } }
      image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    end

    factory :products_section_sub_component do
      contents { { product_id: create(:work, :is_public).id } }
      image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    end

    factory :campaign_sub_component do
      contents { { campaign_id: create(:mobile_page).id } }
      image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    end
  end
end
