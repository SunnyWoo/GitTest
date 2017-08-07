require 'spec_helper'

RSpec.describe 'api/v3/question_categories/index.json.jbuilder', :caching, type: :view do
  let(:question_category) { create(:question_category, questions: [question]) }
  let(:question) { create(:question) }

  it 'renders question_category' do
    assign(:question_categories, [question_category])
    render
    expect(JSON.parse(rendered)).to eq(
      'question_categories' => [{
        'id' => question_category.id,
        'name' => question_category.name,
        'questions' => [{
          'id' => question.id,
          'question' => question.question,
          'answer' => question.answer
        }]
      }]
    )
  end
end
