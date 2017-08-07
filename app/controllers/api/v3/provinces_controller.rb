class Api::V3::ProvincesController < ApiV3Controller
=begin
@api {get} /api/provinces Get provinces
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Province
@apiName Province
@apiSuccessExample {json} Response-Example:
  {
    provinces: [
      { 'id': 1,
        'name': '上海市'
      },
      { 'id': 2,
        'name': '浙江省'
      }
    ]
  }
=end
  def index
    @provinces = Province.normal
    render 'api/v3/provinces/index'
  end
end
