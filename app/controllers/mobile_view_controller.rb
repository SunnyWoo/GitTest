class MobileViewController < ApplicationController
  before_action :find_service, only: [:code]

  def faq
    @question_categories = QuestionCategory.includes(:questions)
  end

  def code
    retrieve_and_send(@service)
  end

  protected

  def find_service
    @service = MobileVerifyService.new(params[:mobile])
  end

  def retrieve_and_send(service)
    @code = service.retrieve_code
    service.send_code
    render json: { success: true }
  end
end
