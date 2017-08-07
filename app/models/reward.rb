# == Schema Information
#
# Table name: rewards
#
#  id          :integer          not null, primary key
#  order_no    :string           not null
#  phone       :string
#  coupon_code :string
#  avatar      :string
#  cover       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Reward < ActiveRecord::Base
  validates :order_no, :coupon_code, :avatar, :cover, presence: true

  before_save :set_phone_from_order_billing_info

  mount_uploader :avatar, DefaultUploader
  mount_uploader :cover, DefaultUploader

  def order
    @order ||= Order.find_by!(order_no: order_no)
  end

  private

  def set_phone_from_order_billing_info
    self.phone = order.billing_info_phone
    if phone.present?
      true
    else
      errors.add(:phone, 'phone is missing')
      false
    end
  end
end
