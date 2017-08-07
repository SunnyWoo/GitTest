class Admin::JobsController < AdminController
  def show
    render json: Sidekiq::Status.get_all(params[:id])
  end
end
