class PhoneFilterService
  CHINA_PHONE_FORMAT = /^(1\d{2})[\-_|\s]?(\d{4})[\-_|\s]?(\d{4})$/
  TAIWAN_PHONE_FORMAT = /^(09\d{2})[\-_|\s]?(\d{3})[\-_|\s]?(\d{3})$/

  def self.run(phones)
    invalid_phones = []
    phones.map! do |phone|
      case phone
      when CHINA_PHONE_FORMAT
        result = phone.match CHINA_PHONE_FORMAT
        result[1] + result[2] + result[3]
      when TAIWAN_PHONE_FORMAT
        result = phone.match TAIWAN_PHONE_FORMAT
        result[1] + result[2] + result[3]
      else
        invalid_phones << phone
        ''
      end
    end
    [phones.reject(&:blank?).join(','), invalid_phones.join(',')]
  end
end
