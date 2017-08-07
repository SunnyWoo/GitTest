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

class Question < ActiveRecord::Base
  translates :question, :answer

  strip_attributes only: %i(question)
  belongs_to :question_category
  validates :question, :question_category_id, presence: true
end
