# == Schema Information
#
# Table name: import_order_succeeds
#
#  id                   :integer          not null, primary key
#  import_order_id      :integer
#  order_id             :integer
#  guanyi_trade_code    :string(255)
#  guanyi_platform_code :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

require 'rails_helper'

RSpec.describe ImportOrderSucceed, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
