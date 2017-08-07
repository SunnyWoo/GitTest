class Api::V1::My::DevicesController < ApiController
  before_action :authenticate_required!

  # Devices list
  #
  # Url : /api/my/devices
  #
  # RESTful : Get
  #
  # Get Example
  #   /api/my/devices
  #
  # Return Example
  #  [
  #    {
  #      "id": 1,
  #      "user_id": 1,
  #      "token": null,
  #      "detail": {},
  #      "os_version": "OS_51",
  #      "device_type": "iOS",
  #      "created_at": "2014-10-22T16:30:22.214+08:00",
  #      "updated_at": "2014-10-22T16:30:22.214+08:00"
  #    }
  #  ]
  #
  # @return [JSON] status 200
  def index
    @devices = current_user.devices
    render json: @devices, root: false
    fresh_when(etag: @devices)
  end

  # Create Device
  #
  # Url : /api/my/devices
  #
  # RESTful : POST
  #
  # POST Example
  #   POST /api/my/devices
  #   {
  #     auth_token: user auth_token,
  #     token: 'xxxx',
  #     os_version: 'iOS99',
  #     device_type: 'iOS',
  #     country_code: 'TW',
  #     timezone: 'Taipei'
  #   }
  #
  # Return Example
  #  {
  #    "id": 2,
  #    "user_id": 1,
  #    "token": "xxxx",
  #    "detail": ,
  #    "os_version": "iOS99",
  #    "device_type": "iOS",
  #    "created_at": "2014-10-22T16:43:56.552+08:00",
  #    "updated_at": "2014-10-22T16:43:56.552+08:00",
  #    "endpoint_arn": "null",
  #    "country_code": "TW",
  #    "timezone": "Taipei"
  #  }
  #
  # @param request auth_token [String] User auth_token
  # @param token [String] device token
  # @param request os_version [String] os version
  # @param request device_type [String] iOS || Android
  # @param request country_code [String] ISO 3166 Alpha-2
  # @param request timezone [String] Time zone name
  # @param idfa [String] Device's uuid for Ad.
  #
  # @return [JSON] status 200
  def create
    @device = current_user.devices.build(api_permitted_params.device)
    if @device.save
      render json: @device, root: false, status: :created
    else
      render json: { status: 'Error', message: @device.errors.full_messages }, status: :bad_request
    end
  end

  # Update Device
  #
  # Url : /api/my/devices/:id
  #
  # RESTful : PUT
  #
  # PUT Example
  #   PUT /api/my/devices/1
  #   {
  #     auth_token: user auth_token,
  #     token: 'update token',
  #     os_version: 'iOS100',
  #   }
  #
  # Return Example
  #  {
  #    "id": 2,
  #    "user_id": 1,
  #    "token": "update token",
  #    "detail": ,
  #    "os_version": "iOS100",
  #    "device_type": "iOS",
  #    "created_at": "2014-10-22T16:43:56.552+08:00",
  #    "updated_at": "2014-10-22T16:43:56.552+08:00",
  #    "endpoint_arn": "null",
  #    "country_code":"TW",
  #    "timezone":"Taipei"
  #  }
  #
  # @param request auth_token [String] User auth_token
  # @param token [String] device token
  # @param os_version [String] os version
  # @param device_type [String] iOS || Android
  # @param country_code [String] ISO 3166 Alpha-2
  # @param timezone [String] Time zone name
  # @param idfa [String] Device's uuid for Ad.
  # @return [JSON] status 200
  def update
    @device = current_user.devices.find(params[:id])
    if @device.update(api_permitted_params.device)
      render json: @device, root: false, status: :ok
    else
      render json: { status: 'Error', message: @device.errors.full_messages }, status: :bad_request
    end
  end

  # Destroy Device
  #
  # Url : /api/my/devices/:id
  #
  # RESTful : DELETE
  #
  # DELETE Example
  #   /api/my/devices/1
  #
  # Return Example
  #  {
  #     "status":"Ok"
  #  }
  #
  # @return [JSON] status 200
  def destroy
    @device = current_user.devices.find(params[:id])
    @device.destroy
    render json: { status: 'Ok' }, status: :ok
  end
end
