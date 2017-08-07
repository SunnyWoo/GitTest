# == Schema Information
#
# Table name: shipping_fees
#
#  id                    :integer          not null, primary key
#  type                  :string(255)
#  province_id           :integer
#  logistics_supplier_id :integer
#  country               :string(255)
#  currency              :string(255)
#  weight                :float
#  price                 :float
#  created_at            :datetime
#  updated_at            :datetime
#

class ShippingFee < ActiveRecord::Base
  belongs_to :province
  belongs_to :logistics_supplier

  GLOBAL_TO_TW_PRICE = 65

  def self.defaut_currency
    Region.china? ? 'CNY' : 'TWD'
  end
end
