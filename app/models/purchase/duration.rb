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

class Purchase::Duration < ActiveRecord::Base
  has_many :histories, class_name: 'Purchase::History'

  def year_month
    "#{year}-#{month}"
  end
end
