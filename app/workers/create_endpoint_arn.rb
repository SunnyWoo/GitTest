class CreateEndpointArn
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(device_id)
    device = Device.find(device_id)
    device.create_endpoint_arn
  end
end
