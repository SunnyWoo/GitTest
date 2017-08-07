#
#  AwsSns::PublishToDevice.new(
#     device: "Object",
#     message: "String",
#     deep_link: "String",
#     notification_id: "Integer",
# )
#  * device is Device Model
#
class AwsSns::PublishToDevice < AwsSnsService
  def initialize(args = {})
    super
    @device = args.delete(:device)
    @message = args.delete(:message)
    @deep_link = args.delete(:deep_link)
    @notification_id = args.delete(:notification_id)
  end

  #  return example
  #    {
  #      :message_id => "24950eba-5f43-5399-84bb-438bdd624f2c",
  #      :response_metadata => {
  #        :request_id=>"53ef285a-946b-5e8c-9a82-656b164ad239"
  #      }
  #    }
  #
  def execute
    return if Region.china?
    raise InvalidDeviceError if @device.nil?
    raise InvalidMessageError if @message.nil?

    option = {}
    option.merge!(deep_link: @deep_link) if @deep_link.present?
    option.merge!(notification_id: @notification_id) if @notification_id.present?

    @message = AwsSnsMessage.new(@message, @device.device_type, option).build

    begin
      res = @sns.publish({
              target_arn: @device.endpoint_arn,
              message: @message,
              message_structure: 'json'
            })
      @device.create_activity(:message_published, { message: @message,
                                                    notification_id: @notification_id }.merge!(res.to_h) )
      return res
    rescue => e
      @device.disable
      return e.message
    end
  end
end
