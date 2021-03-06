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

class ImportOrderSucceed < ActiveRecord::Base
  belongs_to :import_order
  belongs_to :order
end
