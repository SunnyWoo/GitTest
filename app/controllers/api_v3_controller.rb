class ApiV3Controller < ApiV2Controller
  CLIENT_ID_HEADER = 'ClientId'.freeze
  CLIENT_SECRET_HEADER = 'ClientSecret'.freeze

  def resource_owner
    return unless doorkeeper_token.try(:resource_owner_id)
    @resource_owner = ResourceOwner.new(doorkeeper_token.resource_owner_id)
  end

  def current_user
    @current_user ||= resource_owner.try(:user)
  end

  def current_application
    @current_application ||= doorkeeper_token.application
  end

  def doorkeeper_authorize!(*scopes)
    headers = request.headers
    if headers[CLIENT_ID_HEADER].present? && headers[CLIENT_SECRET_HEADER].present?
      client = Doorkeeper::Application.find_by(uid: headers[CLIENT_ID_HEADER], secret: headers[CLIENT_SECRET_HEADER])
      fail InvalidClientError unless client
    else
      super
    end
  end

  protected

  def check_user
    fail CurrentUserRequiredError unless current_user
  end
end
