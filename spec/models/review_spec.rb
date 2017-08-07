# == Schema Information
#
# Table name: reviews
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  work_id    :integer
#  work_type  :string(255)
#  body       :text
#  star       :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Review, type: :model do
  it { should validate_length_of(:body).is_at_least(1).is_at_most(800) }
  it { should validate_numericality_of(:star).is_greater_than_or_equal_to(1)
                                             .is_less_than_or_equal_to(5) }
end
