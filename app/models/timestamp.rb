# == Schema Information
#
# Table name: timestamps
#
#  id           :integer          not null, primary key
#  date         :date
#  timestamp_no :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Timestamp < ActiveRecord::Base
  validates_uniqueness_of :date

  class << self
    def today_timestamp_no
      transaction do
        timestamp = today.lock(true).first
        if timestamp
          timestamp.timestamp_no = timestamp.timestamp_no + 1
          timestamp.save!
        else
          time = Time.now
          timestamp_no = "#{time.year}#{time.month}#{time.day}0001".to_i
          timestamp = create(date: Date.today, timestamp_no: timestamp_no)
        end
        timestamp.timestamp_no
      end
    end
  end
end
