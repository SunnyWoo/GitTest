class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: :create

  def index
    @work = Work.find(params[:id])
    @reviews = @work.reviews.ordered
    # TODO: render what you want
  end

  def create
    @work = Work.find(params[:id])
    @review = @work.reviews.new(create_params)
    @review.user = current_user
    if @review.save
      # TODO: render what you want
    else
      # TODO: render what you want
    end
  end

  private

  def create_params
    params.require(:review).permit(:body, :star)
  end
end
