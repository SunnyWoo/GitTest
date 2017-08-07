# == Schema Information
#
# Table name: purchase_durations
#
#  id         :integer          not null, primary key
#  year       :string(255)
#  month      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Purchase::Duration, type: :model do
  context '#year_month' do
    Given(:duration) { create :purchase_duration, year: '2016', month: 1 }
    Then { duration.year_month == '2016-1' }
  end
end
