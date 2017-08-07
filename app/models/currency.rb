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

class Currency < ActiveRecord::Base
  belongs_to :payable, polymorphic: true

  validates_presence_of :name, :code, :price

  def self.missing_any_currencies?
    missing_currencies.any?
  end

  def self.missing_currencies
    CurrencyType.pluck(:code) - pluck(:code)
  end
end
