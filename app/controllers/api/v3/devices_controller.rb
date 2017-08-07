class Api::V3::DevicesController < ApiV2Controller
  before_action :find_or_initialize_device, only: :update

=begin
@api {PUT} /api/devices/:token Update Device
@apiGroup Devices
@apiName UpdateDevice
@apiVersion 3.0.0
@apiParam {String} token String token
@apiParam {String} os_version OS version, ex: `iOS6`
@apiParam {String="iOS","Android"} device_type Device type
@apiParam {String} country_code ISO 3166 Alpha-2
@apiParam {String} timezone Time zone name
@apiParam {String} idfa Device's uuid for Ad
@apiParam {String} getui_client_id getui client_id
@apiParamExample {json} Request-Example
  # PUT /api/devices/c10a09ae014e34e4a295a
  {
    os_version: 'iOS100',
    device_type: 'iOS',
    country_code: 'TW',
    timezone: 'Taipei',
    idfa: "idfa",
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
    "timezone": null,
    "idfa": "c3b1f0fabbdb65f28c030f53dce402f8"
    }
  }
=end
  def update
    @device.update!(api_permitted_params.device)
    @device.enable
    @device.reload
    render :show
  rescue ArgumentError => e
    fail DeviceError, e
  end

  private

  def find_or_initialize_device
    @device = Device.where(token: params[:token]).first_or_initialize
  end
end
