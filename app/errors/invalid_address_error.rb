class InvalidAddressError < ApplicationError
  def initialize(seg = nil, value = nil, caused_by: nil)
    @seg = seg.to_s
    @value = value.to_s
    super("invalid #{seg} code(#{value})", caused_by: caused_by)
  end

  def message
    I18n.t('errors.invalid_address_error', seg: @seg, value: @value, default: super)
  end
end
