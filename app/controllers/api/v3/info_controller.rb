class Api::V3::InfoController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/info Get API version info data
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup api_version
@apiName ApiInfo
@apiSuccessExample {json} Response-Example:
  {
    "info": {
      "api_version": "v3"
    }
  }
=end
  def show
    render json: { info: { api_version: 'v3' } }
  end
end
