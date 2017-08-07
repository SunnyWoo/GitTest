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

require 'rails_helper'

RSpec.describe WaybillRoute, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
