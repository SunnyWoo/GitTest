=begin
@apiDefine NotificationTrackingResponse
@apiSuccessExample {json} Success-Response:
  HTTP/1.1 201 Created
  {
    "notification_tracking": {
                     "id": 1,
        "notification_id": 1,
           "device_token": "d76295f17cc1f453646b533dbae8a306",
           "country_code": "US",
              "opened_at": "2015-05-27T13:05:58.689+08:00"
    }
  }
=end
class Api::V2::NotificationTrackingsController < ApiV2Controller
  before_action :find_notification, only: :create
=begin
@api {post} /api/notification_trackings Log notification tracking
@apiUse NotificationTrackingResponse
@apiGroup NotificationTracking
@apiName LogNotificationTracking
@apiVersion 2.0.0
@apiParam {Integer} notification_id Notificaion ID
@apiParam {String} device_token Device, APNS or GCM Token
=end
  def create
    render json: @notification_tracking,
           serializer: Api::V2::NotificationTrackingSerializer,
           status: :created
  end

  private

  def find_notification
    notification = Notification.find(params[:notification_id])
    @notification_tracking = notification.notification_trackings.create(notification_tracking_params)
  end

  def notification_tracking_params
    params.permit(:device_token).merge(opened_at: Time.zone.now,
                                       country_code: current_country_code,
                                       ip: request.ip,
                                       os_type: os_type,
                                       os_version: os_version,
                                       device_model: device_model,
                                       app_version: app_version)
  end
end
