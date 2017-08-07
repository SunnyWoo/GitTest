# Aws::SNS::Client doc
# http://docs.aws.amazon.com/sdkforruby/api/Aws/SNS/Client.html
class AwsSnsService
  def initialize(args = {})
    @sns = AWS::SNS::Client.new( access_key_id: Settings.AWS.sns.access_key_id,
                                 secret_access_key: Settings.AWS.sns.secret_access_key,
                                 region: Settings.AWS.sns.region)
  end

  #
  # 取得 AWS SNS 上面的 applicatoin list
  #
  #   return example
  #      [
  #        {
  #          :attributes => {
  #            "Enabled" => "true",
  #            "AppleCertificateExpirationDate" => "2015-12-12T02:39:40Z"
  #          },
  #          :platform_application_arn => "arn:aws:sns:ap-northeast-1:911990202915:app/APNS/staging_apns"
  #        },{
  #          :attributes => {
  #            "Enabled" => "true",
  #            "AppleCertificateExpirationDate" => "2016-01-15T05:41:30Z"
  #          },
  #          :platform_application_arn => "arn:aws:sns:ap-northeast-1:911990202915:app/APNS_SANDBOX/staging_develop_commandp"
  #        }
  #      ]
  def list_platform_applications
    res = @sns.list_platform_applications
    return res ? res[:platform_applications] : nil
  end

  #
  #  list_endpoints_by_platform_application(
  #    # required
  #    platform_application_arn: "String",
  #    next_token: "String",
  #  )
  #
  #
  #  return example
  #     [
  #       {
  #         :attributes => {
  #           "Enabled" => "true",
  #           "CustomUserData" => "commandp test iphone4",
  #           "Token" => "c10a09ae014e34e4a295a760e6cf46a5e31fb3943737fbf2e6d96797a780c953"
  #         },
  #         :endpoint_arn => "arn:aws:sns:ap-northeast-1:911990202915:endpoint/APNS/staging_apns/c6af8c6c-9708-3f2c-9a55-e8081909364f"
  #       }
  #     ]
  def list_endpoints_by_platform_application(params)
    res = @sns.list_endpoints_by_platform_application(params)
    return res ? res[:endpoints] : nil
  end

  class InvalidSubjectError < ApplicationError
    def message
      "subject #{I18n.t('errors.messages.blank')}"
    end
  end

  class InvalidMessageError < ApplicationError
    def message
      "message #{I18n.t('errors.messages.blank')}"
    end
  end

  class InvalidTargetArnError < ApplicationError
    def message
      "target_arn #{I18n.t('errors.messages.blank')}"
    end
  end

  class InvalidTopicArnError < ApplicationError
    def message
      "topic_arn #{I18n.t('errors.messages.blank')}"
    end
  end

  class InvalidDeviceTypeError < ApplicationError
    def message
      I18n.t('notifications.errors.device_type_error', type: AwsSns::BuildMessage.device_type_list.join(','))
    end
  end

  class InvalidDeviceType2Error < ApplicationError
    def message
      I18n.t('notifications.errors.device_type_error', type: Device.device_types.keys.join(','))
    end
  end

  class InvalidEndpointArnError < ApplicationError
    def message
      "DeviceType #{I18n.t('errors.messages.blank')}"
    end
  end

  class InvalidPlatformApplicationArnError < ApplicationError
    def message
      "platform_application_arn #{I18n.t('errors.messages.blank')}"
    end
  end

  class InvalidTokenError < ApplicationError
    def message
      "token #{I18n.t('errors.messages.blank')}"
    end
  end

  class InvalidDeviceError < ApplicationError
    def message
      "device #{I18n.t('errors.messages.blank')}"
    end
  end
end
