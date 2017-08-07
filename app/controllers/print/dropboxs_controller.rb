class Print::DropboxsController < PrintController
  before_action :get_dropbox
  rescue_from Dropbox::API::Error::Unauthorized, with: :authorize

  def authorize
    store_token_in_session(@dropbox.get_request_token)
    redirect_to @dropbox.dropbox_authorize_path(print_dropbox_callback_url)
  end

  def callback
    @access_token = @dropbox.get_access_token(session[:request_token], session[:request_token_secret], params[:oauth_token])
    current_factory.set_dropbox_access_token(@access_token)
    delete_token_in_session
    redirect_to print_dropbox_path
  end

  def index
    @client = current_factory.dropbox_client
  end

  private

  def get_dropbox
    @dropbox = DropboxService.new
  end

  def store_token_in_session(request_token)
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
  end

  def delete_token_in_session
    session.delete(:request_token)
    session.delete(:request_token_secret)
  end
end
