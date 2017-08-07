class ServiceObjectError < StandardError
  attr_reader :caused_by
  def initialize(message = nil, caused_by: nil)
    super(message)
    @caused_by = caused_by
  end

  alias_method :original_message, :message

  def code
    self.class.name
  end

  def as_json(*)
    { message: message, code: code }
  end
end
