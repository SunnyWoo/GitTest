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

require 'rails_helper'

RSpec.describe LogisticsSupplier, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
