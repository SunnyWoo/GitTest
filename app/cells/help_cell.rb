class HelpCell < Cell::Rails
  def sidebar(question_categories = nil)
    @question_categories = question_categories ||
                           QuestionCategory.includes(:questions)
    render
  end
end