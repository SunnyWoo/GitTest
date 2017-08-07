class ApplicationError < StandardError
  attr_reader :caused_by

  def initialize(message = nil, caused_by: nil)
    super(message)
    @caused_by = caused_by
  end

  alias_method :original_message, :message

  def status
    :bad_request
  end

  def as_json(*)
    { error: message, code: self.class.name }
  end
end
