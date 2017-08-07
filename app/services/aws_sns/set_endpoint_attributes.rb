#
#  AwsSns::SetEndpointAttributes.new(device)
#  * device is Device Model
#
#  set endpoint Enabled to true
#
class AwsSns::SetEndpointAttributes < AwsSnsService
  def initialize(device)
    super
    @device = device
  end

  #  return example
  #   {
  #     :response_metadata => {
  #       :request_id => "4a4c1abd-42d3-5a84-9aa3-57ce622fb464"
  #     }
  #   }
  #
  def execute
    return if Region.china?
    begin
      res = @sns.set_endpoint_attributes({
          endpoint_arn: @device.endpoint_arn,
          attributes: {
            'Enabled' => 'true',
            'CustomUserData' => "device_id:#{@device.id} updated_at: #{Time.now}"
          }
        })
      return res
    rescue => e
      return e.message
    end
  end
end
