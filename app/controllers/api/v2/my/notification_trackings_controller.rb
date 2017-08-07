class Api::V2::My::NotificationTrackingsController < ApiV2Controller
  before_action :authenticate_required!
  before_action :find_notification, only: :create

=begin
@api {post} /api/my/notification_tracking Log Notification Tracking
@apiUse NeedAuth
@apiUse NotificationTrackingResponse
@apiGroup My/NotificationTracking
@apiName LogMyNotificationTracking
@apiVersion 2.0.0
@apiParamExample {json} Request-Example
  # POST /api/my/notification_tracking
  {
    "auth_token: "78dfbekrwerbasdf231dbasdf",
    "notification_id": 2,
    "device_token": "d76295f17cc1f453646b533dbae8a306" # Device, APNS, or GCM token
  }
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
    params.permit(:device_token).merge(user_id: current_user.id,
                                       opened_at: Time.zone.now,
                                       country_code: current_country_code,
                                       ip: request.ip,
                                       os_type: os_type,
                                       os_version: os_version,
                                       device_model: device_model,
                                       app_version: app_version)
  end
end
