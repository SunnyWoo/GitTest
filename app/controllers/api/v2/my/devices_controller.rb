class Api::V2::My::DevicesController < ApiV2Controller
  before_action :authenticate_required!
  before_action :find_or_initialize_device, only: :update

=begin
@api {get} /api/my/devices Devices list
@apiUse NeedAuth
@apiGroup My/Devices
@apiName GetMyDevices
@apiVersion 2.0.0
@apiSuccessExample {json} Success-Response:
  {
    "devices": [{
      "id": 1,
      "user_id": 74,
      "token": "7888062c4fb1ffd5874e34933a5670d0",
      "detail": {},
      "os_version": "9.0.2",
      "device_type": "iOS",
      "endpoint_arn": null,
      "getui_client_id": "e5b1f0fabbdb65f28c030f53dce409e8",
      "country_code": null,
      "timezone": null
    }, {
      "id": 22,
      "user_id": 74,
      "token": "asdasdasdsd",
      "detail": {},
      "os_version": "9.0.2",
      "device_type": "iOS",
      "endpoint_arn": null,
      "getui_client_id": "b3b1qwqcveww5f28c030f53dce409e8",
      "country_code": null,
      "timezone": null
    }]
  }
=end
  def index
    @devices = current_user.devices
    render 'api/v3/devices/index'
    fresh_when(etag: @devices)
  end

=begin
@api {put} /api/my/devices/:token Update Device
@apiUse NeedAuth
@apiGroup My/Devices
@apiName UpdateMyDevice
@apiVersion 2.0.0
@apiParamExample {json} Request-Example
  # PUT /api/my/devices/c10a09ae014e34e4a295a
  {
    auth_token: "78dfbekrwerbasdf231dbasdf",
    os_version: 'iOS100',
    device_type: 'iOS',
    country_code: 'TW',
    timezone: 'Taipei',
    getui_client_id: 'e5b1f0fabbdb65f28c030f53dce409e8'
  }
@apiSuccessExample {json} Success-Response:
  {
    "device": {
    "id": 1,
    "user_id": 74,
    "token": "7888062c4fb1ffd5874e34933a5670d0",
    "detail": {},
    "os_version": "9.0.2",
    "device_type": "iOS",
    "endpoint_arn": null,
    "getui_client_id": "e5b1f0fabbdb65f28c030f53dce409e8",
    "country_code": null,
    "timezone": null
    }
  }
=end
  def update
    @device.update!(api_permitted_params.device)
    @device.enable
    @device.reload
    render 'api/v3/devices/show'
  rescue ArgumentError => e
    raise DeviceError.new(e)
  end

  private

  def find_or_initialize_device
    @device = Device.where(token: params[:token]).first_or_initialize
    @device.user_id = current_user.id
  end
end
