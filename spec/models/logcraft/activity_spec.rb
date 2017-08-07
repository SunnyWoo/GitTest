# == Schema Information
#
# Table name: logcraft_activities
#
#  id             :integer          not null, primary key
#  key            :string(255)
#  trackable_id   :integer
#  trackable_type :string(255)
#  user_id        :integer
#  user_type      :string(255)
#  source         :json
#  message        :text
#  extra_info     :json
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

RSpec.describe Logcraft::Activity, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
