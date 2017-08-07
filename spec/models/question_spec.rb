# == Schema Information
#
# Table name: questions
#
#  id                   :integer          not null, primary key
#  question             :string(255)
#  answer               :text
#  question_category_id :integer
#  created_at           :datetime
#  updated_at           :datetime
#

require 'spec_helper'

RSpec.describe Question, type: :model do
  it { is_expected.to strip_attribute :question }
  it { is_expected.to belong_to(:question_category) }
  it { is_expected.to validate_presence_of(:question) }
  it { is_expected.to validate_presence_of(:question_category_id) }
end
