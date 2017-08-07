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

describe BillingProfileSerializer do
  it 'works' do
    profile = create(:billing_info)
    json = JSON.parse(BillingProfileSerializer.new(profile).to_json)
    expect(json).to eq({
      'billing_profile' => {
        'address' => profile.address,
        'city' => profile.city,
        'name' => profile.name,
        'phone' => profile.phone,
        'state' => profile.state,
        'zip_code' => profile.zip_code,
        'country' => profile.country,
        'created_at' => profile.created_at.as_json,
        'updated_at' => profile.updated_at.as_json,
        'country_code' => profile.country_code,
        'shipping_way' => profile.shipping_way,
        'email' => profile.email
      }
    })
  end
end
