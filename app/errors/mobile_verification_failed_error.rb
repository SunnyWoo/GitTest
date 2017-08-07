class MobileVerificationFailedError < AuthenticationFailedError
  def message
    I18n.t 'errors.invalid_mobile_code'
  end
end
