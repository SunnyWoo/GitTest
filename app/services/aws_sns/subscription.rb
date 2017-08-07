#  把 endpoint_arn 加入某個 topic
#  AwsSns::Subscription.new(
#     endpoint_arn: "String",
# )
#  * device token 向AWS 註冊的ARN
#
#
class AwsSns::Subscription < AwsSnsService
  def initialize(args = {})
    super
    @topic_arn = args.delete(:topic_arn) || Settings.AWS.sns.topic_arn
    @endpoint_arn = args.delete(:endpoint_arn)
  end


  #   return example
  #       {
  #         :subscription_arn => "arn:aws:sns:ap-northeast-1:911990202915:commandp_staging_topics:e35845f9-551b-4ef6-bb7a-b105755ef4b6",
  #         :response_metadata => {
  #           :request_id => "976ddd07-ad13-56e8-b378-9031457cae0b"
  #         }
  #       }
  # @return JSON
  def execute
    return if Region.china?
    raise InvalidTopicArnError if @topic_arn.nil?
    raise InvalidEndpointArnError if @endpoint_arn.nil?

    res = @sns.subscribe(
      topic_arn: @topic_arn,
      protocol: 'application',
      endpoint: @endpoint_arn
    )
    return res
  end
end
