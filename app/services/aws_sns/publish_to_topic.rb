#
#  AwsSns::PublishToTopic.new(
#     target_arn: "String",
#     message: "String",
#     deep_link: "String",
#     notification_id: "Integer",
# )
#
class AwsSns::PublishToTopic < AwsSnsService
  def initialize(args = {})
    super
    @topic_arn = args.delete(:topic_arn) || Settings.AWS.sns.topic_arn
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
    raise InvalidTopicArnError if @topic_arn.nil?
    raise InvalidMessageError if @message.nil?

    option = {}
    option.merge!(deep_link: @deep_link) if @deep_link.present?
    option.merge!(notification_id: @notification_id) if @notification_id.present?

    message = AwsSnsMessage.new(@message, 'all', option).build
    begin
      res = @sns.publish({
              topic_arn: @topic_arn,
              message: message,
              message_structure: 'json'
            })
      return res
    rescue => e
      return e.message
    end
  end
end
