class PayResultsController < ActionController::Base
  def show
    if request.post?
      redirect_to url_for(params)
    else
      neweb = NewebMPPService.new
      if neweb.valid_return_params?(params)
        render json: params
      else
        render json: {error: 'Invalid parameters.'}, error: :bad_request
      end
    end
  end
end
