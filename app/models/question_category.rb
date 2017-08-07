# == Schema Information
#
# Table name: question_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class QuestionCategory < ActiveRecord::Base
  translates :name

  strip_attributes only: %i(name)
  has_many :questions
  validates :name, presence: true
end
