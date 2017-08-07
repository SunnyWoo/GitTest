#
#  AwsSns::CreatePlatformEndpoint.new(device)
#  * device is Device Model
#
class AwsSns::CreatePlatformEndpoint < AwsSnsService
  def initialize(device)
    super
    @device = device
  end

  #  return example
  #     {
  #       :endpoint_arn => "arn:aws:sns:ap-northeast-1:911990202915:endpoint/APNS/staging_apns/c6af8c6c-9708-3f2c-9a55-e8081909364f",
  #       :response_metadata => {
  #         :request_id=>"70868bf3-ce2c-5979-89d2-c6ca87b09dd8"
  #       }
  #     }
  #
  def execute
    return if Region.china?
    begin
      res = @sns.create_platform_endpoint({
          platform_application_arn: @device.platform_application_arn,
          token: @device.token,
          custom_user_data: "device_id:#{@device.id} created_at:#{Time.now}",
        })
      return res
    rescue => e
      return e.message
    end
  end
end
