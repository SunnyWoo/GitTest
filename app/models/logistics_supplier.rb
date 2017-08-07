# == Schema Information
#
# Table name: logistics_suppliers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  position   :integer
#

class LogisticsSupplier < ActiveRecord::Base
  has_many :shipping_fees
  has_many :packages
end
