# == Schema Information
#
# Table name: waybill_routes
#
#  id             :integer          not null, primary key
#  order_id       :integer
#  route_no       :string(255)
#  mail_no        :string(255)
#  accept_time    :datetime
#  accept_address :string(255)
#  remark         :string(255)
#  op_code        :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  package_id     :integer
#

FactoryGirl.define do
  factory :waybill_route do
    
  end

end
