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

class ShippingInfo < BillingProfile
  validates :shipping_way, presence: true

  class << self
    def shipping_way_list(country = 'US')
      case country
      when 'US' then { 'standard' => 0, 'express' => 1 }
      else shipping_ways
      end
    end
  end

  def clone_shipping_info_attributes
    {
      address: address,
      city: city,
      name: name,
      phone: phone,
      state: state,
      zip_code: zip_code,
      country: country,
      country_code: country_code,
      shipping_way: shipping_way,
      email: email,
      address_name: address_name,
      address_data: address_data,
      memo: memo
    }
  end
end
