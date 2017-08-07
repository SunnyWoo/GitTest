class SmsService
  attr_reader :provider

  def initialize(provider:)
    @provider = case provider.to_sym
                when :sms_get then SmsGetService.new
                when :sms_king then SmsKingService.new
                when :emay then ChinaSms::EmayService.new(type: 'captcha')
                when :emay_marking then ChinaSms::EmayService.new(type: 'marketing')
                else fail NoSmsProviderError, caused_by: provider
                end
  end

  def execute(phones, content, options = {})
    provider.execute(phones, content, options)
  rescue
    rollback_provider(provider).execute(phones, content, options)
  end

  protected

  def phone_filter
    @phone_filter ||= PhoneFilterService
  end

  def filter_phones(phones)
    phones = phones.split(',').map(&:strip) if phones.is_a?(String)
    phone_filter.run(phones)
  end

  def default_format_result
    { status: 'pending', message: '' }
  end

  def rollback_provider(provider)
    case provider.class.name
    when 'SmsGetService'
      SmsKingService.new
    when 'SmsKingService'
      SmsGetService.new
    end
  end
end
