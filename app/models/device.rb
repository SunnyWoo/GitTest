# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  token           :string(255)
#  detail          :text
#  os_version      :string(255)
#  device_type     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  endpoint_arn    :string(255)
#  country_code    :string(255)
#  timezone        :string(255)
#  is_enabled      :boolean          default(TRUE)
#  getui_client_id :string(255)
#  idfa            :string(255)
#

class Device < ActiveRecord::Base
  include Logcraft::Trackable
  include ActsAsIsEnabled

  belongs_to :user

  store :detail

  validates :os_version, :device_type, :token, presence: true
  enum device_type: [:iOS, :Android]

  after_create :delay_create_endpoint_arn
  after_save :update_endpoint_arn

  scope :available, -> { where('endpoint_arn is not null').enabled }

  def delay_create_endpoint_arn
    CreateEndpointArn.perform_in(5.second, id) unless Region.china?
  end

  def create_endpoint_arn
    return if Region.china?
    if endpoint_arn.nil?
      res = AwsSns::CreatePlatformEndpoint.new(self).execute
      begin
        update! endpoint_arn: res[:endpoint_arn]
        endpoint_arn_subscription
      rescue
        create_activity(:create_endpoint_arn_error, message: res.to_s)
      end
    else
      AwsSns::SetEndpointAttributes.new(self).execute
    end
  end

  def update_endpoint_arn
    AwsSns::SetEndpointAttributes.new(self).execute if endpoint_arn.present?
  end

  def endpoint_arn_subscription
    AwsSns::Subscription.new(endpoint_arn: endpoint_arn).execute
  end

  def platform_application_arn
    Settings.AWS.sns.arn.send(device_type)
  end
end
