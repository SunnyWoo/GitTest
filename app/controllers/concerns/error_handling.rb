module ErrorHandling
  extend ActiveSupport::Concern

  included do
    include RedirectHelper
    include ErrorSolver

    rescue_from ApplicationError, with: :error_handler
  end

  def error_handler(ex)
    return render_404 if ex.is_a?(RecordNotFoundError) && ex.message.match(I18n.t('errors.record_not_found'))

    respond_to do |f|
      f.html do
        flash[:alert] = ex.message
        redirect_to_back_or_default
      end

      f.pdf do
        flash[:alert] = ex.message
        redirect_to_back_or_default
      end

      f.js do
        render json: ex, status: ex.status
      end

      f.json do
        render json: ex, status: ex.status
      end
    end
  end
end
