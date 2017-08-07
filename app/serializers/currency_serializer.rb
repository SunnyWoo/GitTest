# == Schema Information
#
# Table name: currencies
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  code             :string(255)
#  price            :float
#  product_model_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  coupon_id        :integer
#  payable_id       :integer
#  payable_type     :string(255)
#

# NOTE: not used in v3 api, remove me later
class CurrencySerializer < ActiveModel::Serializer
  attributes :name, :code, :price
end
