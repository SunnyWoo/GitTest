# == Schema Information
#
# Table name: billing_profiles
#
#  id            :integer          not null, primary key
#  address       :text
#  city          :string(255)
#  name          :string(255)
#  phone         :string(255)
#  state         :string(255)
#  zip_code      :string(255)
#  country       :string(255)
#  billable_id   :integer
#  billable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  country_code  :string(255)
#  shipping_way  :integer          default(0)
#  email         :string(255)
#  type          :string(255)
#  address_name  :string(255)
#  memo          :hstore
#  province_id   :integer
#  address_data  :json
#

require 'spec_helper'

describe ShippingInfo do
  it 'FactoryGirl' do
    expect( build(:shipping_info) ).to be_valid
  end

  context '#clone_shipping_info_attributes' do
    Given(:shipping_info) { create :shipping_info }
    Given(:shipping_info_attributes) do
      {
        address: shipping_info.address,
        city: shipping_info.city,
        name: shipping_info.name,
        phone: shipping_info.phone,
        state: shipping_info.state,
        zip_code: shipping_info.zip_code,
        country: shipping_info.country,
        country_code: shipping_info.country_code,
        shipping_way: shipping_info.shipping_way,
        email: shipping_info.email,
        address_name: shipping_info.address_name,
        address_data: shipping_info.address_data,
        memo: shipping_info.memo
      }
    end
    Then { shipping_info.clone_shipping_info_attributes == shipping_info_attributes }
  end
end
