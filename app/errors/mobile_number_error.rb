class MobileNumberError < ApplicationError
  def message
    I18n.t 'errors.mobile_number_error'
  end
end
