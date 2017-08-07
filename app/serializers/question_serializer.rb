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

# NOTE: not used in v3 api, remove me later
class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :question, :answer
end
