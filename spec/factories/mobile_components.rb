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
#  contents       :json
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :mobile_component do
    key { MobileComponent::KEYS.sample }
    parent_id 1
    position 1
    image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }

    factory :kv_mobile_component do
      key 'kv'
      sub_components { [create(:kv_sub_component)] }
    end

    factory :ticker_mobile_component do
      key 'ticker'
      sub_components { [create(:kv_sub_component)] }
    end

    factory :product_line_mobile_component do
      key 'product_line'
      sub_components { [create(:kv_sub_component)] }
    end

    factory :redeem_mobile_component do
      key 'redeem'
    end

    factory :campaign_section_mobile_component do
      key 'campaign_section'
      sub_components { [create(:campaign_sub_component)] }
    end

    factory :products_section_mobile_component do
      key 'products_section'
      contents {
        {
          section_title: 'ProductTitle',
          section_color: '#123456',
          product_type: 'type_b'
        }
      }
      image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
      sub_components { [create(:products_section_sub_component)] }
    end

    factory :products_section_with_designer_mobile_component do
      key 'products_section'
      contents {
        {
          section_title: 'ProductTitle',
          section_color: '#123456',
          product_type: 'type_b',
          designer_id: create(:designer).id
        }
      }
      image { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
      sub_components { [create(:products_section_sub_component)] }
    end

    factory :tab_section_mobile_component do
      key 'tab_section'
      sub_components { [create(:sub_mobile_component)] }
    end

    factory :media_section_mobile_component do
      key 'media_section'
      sub_components { [create(:sub_component_with_image)] }
    end

    factory :create_section_mobile_component do
      key 'create_section'
      sub_components { [create(:sub_component_with_image)] }
    end

    factory :description_section_mobile_component do
      key 'description_section'
      sub_components { [create(:sub_component_with_image)] }
    end

    factory :download_section_mobile_component do
      key 'download_section'
      sub_components { [create(:sub_component_with_image)] }
    end
  end
end
