class DropboxService
  def initialize
    @consumer = Dropbox::API::OAuth.consumer(:authorize)
    @request_token = @consumer.get_request_token
  end

  def dropbox_authorize_path(callback_path)
    @request_token.authorize_url(oauth_callback: callback_path)
  end

  def get_request_token
    @request_token
  end

  def get_access_token(request_token, request_token_secret, oauth_token)
    auth_request_token = OAuth::RequestToken.new(@consumer, request_token, request_token_secret)
    @access_token = auth_request_token.get_access_token(oauth_verifier: oauth_token)
  end
end
