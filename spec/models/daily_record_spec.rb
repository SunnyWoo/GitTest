# == Schema Information
#
# Table name: daily_records
#
#  id         :integer          not null, primary key
#  type       :string
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  target_ids :integer          default([]), is an Array
#

require 'rails_helper'

RSpec.describe DailyRecord, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
