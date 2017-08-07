# Only push to APNS(iOS)
#
# push_message_to_apns = Getui::PushMessageToApns.new(
#   message: 'String',
#   deeplink: 'String',
#   device_token: 'String'
# )
#
# push_message_to_apns.execute
#
class Getui::PushMessageToApns < GetuiService
  attr_accessor :message, :deeplink, :device_token

  def initialize(args = {})
    super
    @message = args.delete(:message)
    @deeplink = args.delete(:deeplink)
    @device_token = args.delete(:device_token)
  end

  # return example
  #     {
  #         "taskId" => "OSAPNS-0731_N8HfuMDgxQ8fWihD6GeRdA",
  #         "result" => "ok"
  #     }
  def execute
    raise InvalidError.new(caused_by: 'Message') if @message.nil?
    raise InvalidError.new(caused_by: 'DeviceToken') if @device_token.nil?

    template = IGeTui::NotificationTemplate.new
    template.set_push_info(nil, 1, @message, nil, { deeplink: @deeplink } )

    single_message = IGeTui::SingleMessage.new
    single_message.data = template

    begin
      @pusher.push_message_to_apns(single_message, @device_token)
    rescue => e
      return e
    end
  end
end
