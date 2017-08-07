class CommentsController < ApplicationController
  def create
    @comment = Comment.create(params.require(:comment).permit(:email, :content))
    @comments = Comment.order('created_at desc').paginate(page: params[:page], per_page: 100)
  end
end
