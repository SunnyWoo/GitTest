class PingppRailsError < ApplicationError
  attr_reader :pingpp_error

  def initialize(pingpp_error, caused_by: nil)
    super(pingpp_error.message, caused_by: caused_by)
    @pingpp_error = pingpp_error
  end

  def status
    @pingpp_error.http_status || :bad_request
  end

  def as_json(*)
    { error: message, code: pingpp_error.class.name }
  end
end
