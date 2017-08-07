class PhoneNumberMissingError < ServiceObjectError
  def message
    '未提供手機號碼'
  end
end
