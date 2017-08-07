class TokensController < Doorkeeper::TokensController
  def create
    response = strategy.authorize
    headers.merge! response.headers
    self.response_body = response.body.to_json
    self.status        = response.status
    format_error_body(response_body.first) if status.in? [401, 403]
  rescue Doorkeeper::Errors::DoorkeeperError => e
    auth_error_hash = params[:__auth_error]
    if auth_error_hash.present?
      error_type = auth_error_hash.delete(:type)
      error_description = auth_error_hash.delete(:description)
      error = get_error_response_from_exception e
      headers.merge! error.headers
      self.response_body = { error: 'invalid grant',
                             error_type: error_type, # for legacy API compatible
                             code: error_type,
                             detail: error_description }.to_json
      self.status        = error.status
    else
      handle_token_exception e
    end
  end

  private

  def handle_token_exception(*)
    super
    format_error_body(response_body)
  end

  def format_error_body(error_json_string)
    original_error = JSON.parse(error_json_string)
    self.response_body = {
      code: original_error['error'],
      error: original_error['error_description'],
      error_type: original_error['error']
    }.to_json
  end
end
