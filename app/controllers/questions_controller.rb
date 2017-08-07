class QuestionsController < ApplicationController
  def index
    @question_categories = QuestionCategory.includes(:questions)
    set_meta_tags title: t('questions.title'),
                  description: I18n.t('questions.description'),
                  og: {
                    title: "#{t('site.name')} | #{t('questions.title')}",
                    description: I18n.t('questions.description'),
                    image: view_context.asset_url('seo/web_seo_100_yl_home.jpg')
                  }
  end
end
