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

class DailyRecord < ActiveRecord::Base
end
