module LogcraftForApi
  def user_agent
    request.headers['HTTP_USER_AGENT']
  end

  USER_AGENT_PATTERN = /^commandp_(?<app_version>[^_]*)_(?<os_type>[^_]*)_(?<os_version>[^_]*)_(?<device_model>.*)/
  def parsed_user_agent
    @parsed_user_agent ||= USER_AGENT_PATTERN.match(user_agent) || {}
  end

  delegate :remote_ip, to: :request

  def os_type
    parsed_user_agent[:os_type] || 'Unknown'
  end

  def os_version
    parsed_user_agent[:os_version] || 'Unknown'
  end

  def app_version
    parsed_user_agent[:app_version] || 'Unknown'
  end

  def device_model
    parsed_user_agent[:device_model] || 'Unknown'
  end

  def log_with_current_user(model)
    model.logcraft_user = current_user
    model.logcraft_source = { channel: 'api',
                              ip: remote_ip,
                              os_type: os_type,
                              os_version: os_version,
                              app_version: app_version,
                              device_model: device_model,
                              user_agent: user_agent }

    try(:current_application) do |application|
      model.logcraft_source[:oauth_app_id] = application.id
    end
  end
end
