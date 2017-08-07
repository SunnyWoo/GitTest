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

describe QuestionSerializer do
  context 'Regular format' do
    Given!(:question) { create(:question) }
    Given(:json) { JSON.parse(QuestionSerializer.new(question).to_json, symbolize_names: true) }
    Then do
      json[:question] == {
        id: question.id,
        question: question.question,
        answer: question.answer
      }
    end
  end
end
