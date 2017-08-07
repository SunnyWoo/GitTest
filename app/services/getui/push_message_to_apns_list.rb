# Only push to APNS(iOS)
#
# push_message_to_apns_list = Getui::PushMessageToApnsList.new(
#   message: 'String',
#   deeplink: 'String',
#   device_tokens: 'Array'
# )
#
# push_message_to_apns_list.execute
#
class Getui::PushMessageToApnsList < GetuiService
  attr_accessor :message, :deeplink, :device_tokens

  def initialize(args = {})
    super
    @message = args.delete(:message)
    @deeplink = args.delete(:deeplink)
    @device_tokens = args.delete(:device_tokens)
  end

  # return example
  #    {
  #      "result" => "ok",
       # "details" => {
  #        "ad2ba49c177e34d5a4c292d8a316568e5bfc1e7bac62056e5347d82fd9111053" => "Success"
  #      },
  #      "contentId" => "OSAPNL-0803_o51JYsIKNJ705AcMhpiH66"
  #    }
  def execute
    raise InvalidError.new(caused_by: 'Message') if @message.nil?
    raise InvalidError.new(caused_by: 'DeviceTokens') if @device_tokens.nil?

    template = IGeTui::NotificationTemplate.new
    template.set_push_info(nil, 1, @message, nil, { deeplink: @deeplink } )

    single_message = IGeTui::SingleMessage.new
    single_message.data = template

    begin
      apn_content_id = @pusher.get_apn_content_id(single_message)
      @pusher.push_message_to_apns_list(apn_content_id, device_tokens)
    rescue => e
      return e
    end
  end
end
