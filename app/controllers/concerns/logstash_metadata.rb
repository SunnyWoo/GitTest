module LogstashMetadata
  extend ActiveSupport::Concern

  included do
    include ConvertHelper

    def append_info_to_payload(payload)
      super
      payload[:request_id] = request.uuid
      payload[:session_id] = request.session[:session_id] rescue nil
      payload[:ip] = request.remote_ip
      payload[:environment] = Rails.env
      payload[:region] = Region.region
      payload[:site] = request.path =~ /api/ ? 'api' : 'user'
      payload[:user_agent] = request.user_agent
      payload[:access_token] = try(:doorkeeper_token) { |doorkeeper_token| doorkeeper_token.token }
      payload[:request_params] = convert_params(request.params)

      payload[:user] = try(:current_user).try(:email)
      payload[:admin] = try(:current_admin).try(:email)
    end
  end
end
