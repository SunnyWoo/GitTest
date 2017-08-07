class OAuth2Error < ApplicationError
  def initialize(message = nil, detail = nil, caused_by: nil)
    super(message, caused_by: caused_by)
    @detail = detail
  end

  def as_json(*)
    super.merge({ detail: @detail})
  end
end
