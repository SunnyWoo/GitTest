# == Schema Information
#
# Table name: refunds
#
#  id         :integer          not null, primary key
#  order_id   :integer
#  refund_no  :string(255)
#  amount     :float
#  note       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Refund < ActiveRecord::Base
  belongs_to :order
  validates :order_id, presence: true

  after_create :export_order_report_to_redis
  delegate :export_order_report_to_redis, to: :order

  def render_twd_amount
    order.render_twd(amount)
  end

  def to_target_currency_amount(target_currency = order.currency)
    return amount if target_currency == order.currency
    default_currency_type = CurrencyType.find_by!(code: order.currency)
    target_currency_type = CurrencyType.find_by!(code: target_currency)
    amount * default_currency_type.rate / target_currency_type.rate
  end
end
