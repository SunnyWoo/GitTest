module LogstashHandler
  extend ActiveSupport::Concern

  protected

  def set_request_filter
    Thread.current[:request] = request
  end

  def set_uuid_session_id
    session_id = request.session[:session_id] rescue nil
    Thread.current[:log_uuid_session_id] = [request.uuid, session_id]
  end
end
