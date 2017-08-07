# == Schema Information
#
# Table name: price_tiers
#
#  id          :integer          not null, primary key
#  tier        :integer
#  prices      :json
#  created_at  :datetime
#  updated_at  :datetime
#  description :string(255)
#

class PriceTier < ActiveRecord::Base
  serialize :prices, Hashie::Mash.pg_json_serializer

  validates :tier, :prices, presence: true
  validate :validate_all_prices_are_present
  validate :validate_all_prices_are_positive

  scope :ordered, -> { order('tier asc') }
  # pg 預設拿出來都是字串, 得手動改 float 才能拿來排序
  scope :order_by_twd_price, -> { order("CAST(price_tiers.prices->>'TWD' AS FLOAT) ASC") }

  def data=(params)
    self.tier = params.delete('tier')
    self.description = params.delete('description')
    self.prices = params
  end

  def prices=(prices)
    super prices.each_with_object({}) { |(key, value), hash| hash[key] = value.to_f }
  end

  def as_json(*)
    prices.merge('id' => id, 'tier' => tier, 'description' => description)
  end

  def price_in_currency(currency)
    [prices[currency], currency].join(' ')
  end

  private

  def validate_all_prices_are_present
    prices.values.each do |value|
      errors.add(:prices, :blank) if value.blank? || (value == 0)
    end
  end

  def validate_all_prices_are_positive
    if prices.values.any?{ |value| value.to_f <= 0 }
      errors.add(:prices, "can\'t be negative")
    end
  end
end
