# == Schema Information
#
# Table name: question_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

RSpec.describe QuestionCategory, type: :model do
  it { is_expected.to strip_attribute(:name) }
  it { should have_many(:questions) }
  it { should validate_presence_of(:name) }
end
