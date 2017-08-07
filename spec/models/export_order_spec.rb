# == Schema Information
#
# Table name: export_orders
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe ExportOrder, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
