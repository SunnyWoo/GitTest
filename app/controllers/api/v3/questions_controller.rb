class Api::V3::QuestionsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/questions Get Questions list
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Questions
@apiName QuestionsList
@apiSuccessExample {json} Response-Example:
 {
    "question_categories": [
      {
        "id": 1,
        "name": "購物",
        "questions": [
          {
            "id": 1,
            "question": "Why so serious?",
            "answer": "HaHaHaHaHaHaHa Let's put some smile on your face!"
          }
        ]
      }
    ]
  }
=end
  def index
    @question_categories = QuestionCategory.includes(:questions)
    render 'api/v3/question_categories/index'
  end
end
