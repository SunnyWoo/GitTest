class Admin::MessagesController < AdminController
  def index
    @search = Message.ordered.ransack(params[:q])
    @messages = @search.result.page(params[:page])
  end

  def show
    @message = Message.find(params[:id])
    render text: @message.body
  end

  def resend
    @message = Message.find(params[:id])
    @message.resend
    render nothing: true
  end
end
