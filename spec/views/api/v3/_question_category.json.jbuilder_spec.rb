require 'spec_helper'

RSpec.describe 'api/v3/_question_category.json.jbuilder', :caching, type: :view do
  let(:question_category) { create(:question_category, questions: [question]) }
  let(:question) { create(:question) }

  it 'renders question_category' do
    render 'api/v3/question_category', question_category: question_category
    expect(JSON.parse(rendered)).to eq(
      'id' => question_category.id,
      'name' => question_category.name,
      'questions' => [{
        'id' => question.id,
        'question' => question.question,
        'answer' => question.answer
      }]
    )
  end
end
