class Api::V1::ProductModelsController < ApiController
  skip_before_action :authenticate_by_token

  # Product Model List
  #
  # Url -/api/product_models
  #
  # RESTful - Get
  #
  # Get Example
  #  /api/product_models
  #
  # Return Example
  #  [
  #    {
  #      "name": "iphone8",
  #      "description": "iphone8 case",
  #      "currencies": [
  #        {
  #          "name": "U.S. Dollar",
  #          "code": "USD",
  #          "price": 99.9
  #        },{
  #          "name": "TWD",
  #          "code": "TWD",
  #          "price": 3000
  #        }
  #      ]
  #    },{
  #      "name": "iphone7",
  #      "description": "iphone8 case",
  #      "currencies": [
  #        {
  #          "name": "U.S. Dollar",
  #          "code": "USD",
  #          "price": 70
  #        },{
  #          "name": "TWD",
  #          "code": "TWD",
  #          "price": 2100
  #        }
  #      ]
  #    }
  #  ]
  #
  # @return [JSON] status 200
  def index
    @product_models = ProductModel.all
    render json: @product_models, root: false
    fresh_when(etag: @product_models)
  end
end
