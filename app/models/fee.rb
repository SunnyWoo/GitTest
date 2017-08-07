# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Fee < ActiveRecord::Base
  has_many :currencies, as: :payable, dependent: :destroy
  accepts_nested_attributes_for :currencies

  validates_presence_of :name
  validates_uniqueness_of :name

  def price_in_currency(currency)
    currencies.where(code: currency).first.try(:price)
  end

  def build_currencies_set
    CurrencyType.all.each do |type|
      currencies.build(name: type.name, code: type.code)
    end
  end
end
