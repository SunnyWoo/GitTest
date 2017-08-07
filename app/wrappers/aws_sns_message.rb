class AwsSnsMessage
  def initialize(message, device_type, args = {})
    @message = message
    @device_type = device_type.downcase
    @deep_link = args.delete(:deep_link)
    @notification_id = args.delete(:notification_id)
  end

  def build
    raise InvalidDeviceTypeError if !AwsSnsMessage.device_type_list.include?(@device_type)

    message = send("#{@device_type}_message", @message)
    message.to_json
  end

  def self.device_type_list
    ['ios', 'android','all']
  end

  private

  # 產生 apns(iOS) 所使用的 json message
  # return json
  def ios_message(message)
    aps = {
      alert: @message,
      sound: 'default',
      badge: 1
    }
    aps.merge!(deep_link: "#{Settings.deeplink_protocol}://#{@deep_link}") if @deep_link.present?
    aps.merge!(notification_id: @notification_id) if @notification_id.present?
    key = ['production_ready', 'production'].include?(Rails.env) ? 'APNS' : 'APNS_SANDBOX'
    {
      key => {
        aps: aps
      }.to_json
    }
  end

  # 產生 gcm(Android) 所使用的 json message
  # return json
  def android_message(message)
    data = {
      message: message,
    }
    data.merge!(deep_link: "#{Settings.deeplink_protocol}://#{@deep_link}") if @deep_link.present?
    data.merge!(notification_id: @notification_id) if @notification_id.present?
    {
      'GCM' => {
        data: data
      }.to_json
    }
  end

  def all_message(message)
    ios_message = ios_message(message)
    android_message = android_message(message)
    build_message = ios_message.merge(android_message)
    build_message = build_message.merge({ default: message })
  end

  class InvalidDeviceTypeError < ApplicationError
    def message
      I18n.t('notifications.errors.device_type_error', type: AwsSnsMessage.device_type_list.join(','))
    end
  end
end
