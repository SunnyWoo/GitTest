# == Schema Information
#
# Table name: reports
#
#  id                    :integer          not null, primary key
#  order_id              :integer
#  user_id               :integer
#  user_role             :string(255)
#  order_item_num        :integer
#  price                 :integer
#  coupon_price          :integer
#  shipping_fee          :integer
#  country_code          :string(255)
#  platform              :string(255)
#  date                  :date
#  created_at            :datetime
#  updated_at            :datetime
#  subtotal              :integer
#  refund                :integer
#  total                 :integer
#  shipping_fee_discount :integer
#

class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :order

  validates_uniqueness_of :order_id

  before_create :check_user_role

  def self.create_or_update_by(params)
    report = find_by!(order_id: params[:order_id])
    params.delete(:order_id)
    report.update!(params) # 處理退款更新
  rescue ActiveRecord::RecordNotFound
    create!(params)
  end

  private

  def check_user_role
    self.user_role = user.role if user_role.nil? && user
  end
end
