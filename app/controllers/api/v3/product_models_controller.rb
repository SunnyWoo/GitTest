class Api::V3::ProductModelsController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :find_product_model, only: [:show, :des_images]

=begin
@api {get} /api/product_models get all available product_models info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup ProductModels
@apiName ProductModelIndex
@apiParamExample {json} Response-Example:
{
  "products": [
    {
      "id": 4,
      "key": "iphone_6_cases",
      "name": "iPhone 6 手機殼",
      "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 \r\n- 熱轉印特殊防刮抗磨塑料",
      "prices": {
        "TWD": 899,
        "USD": 29.95,
        "JPY": 3480,
        "HKD": 229
      },
      "customized_special_prices": null,
      "design_platform": {
        "ios": true,
        "android": true,
        "website": true
      },
      "customize_platform": {
        "ios": false,
        "android": false,
        "website": true
      },
      "placeholder_image": null,
      "width": 87,
      "height": 150,
      "dpi": 300,
      "background_image": null,
      "overlay_image": null,
      "padding_top": "0.0",
      "padding_right": "0.0",
      "padding_bottom": "0.0",
      "padding_left": "0.0",
      "specs": [
        {
          "id": 4,
          "name": "iPhone 6 手機殼",
          "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕熱轉印特殊防刮抗磨塑料",
          "width": 87,
          "height": 150,
          "dpi": 300,
          "background_image": null,
          "overlay_image": null,
          "padding_top": "0.0",
          "padding_right": "0.0",
          "padding_bottom": "0.0",
          "padding_left": "0.0",
          "__deprecated": "WorkSpec is not longer available"
        }
      ]
    }
  ]
}
=end

  def index
    @products = ProductModel.includes(:currencies, :translations).available
  end

=begin
@api {get} /api/product_models/:id Get the product_model info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup ProductModels
@apiName GetProductModels
@apiParam {Integer} id product_model id or product_model key
@apiSuccessExample {json} Response-Example:
{
  "product_model": {
    "id": 4,
    "key": "iphone_6_cases",
    "name": "iPhone 6 手機殼",
    "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 \r\n- 熱轉印特殊防刮抗磨塑料",
    "prices": {
      "TWD": 899,
      "USD": 29.95,
      "JPY": 3480,
      "HKD": 229
    },
    "customized_special_prices": null,
    "design_platform": {
      "ios": true,
      "android": true,
      "website": true
    },
    "customize_platform": {
      "ios": false,
      "android": false,
      "website": true
    },
    "placeholder_image": null,
    "width": 87,
    "height": 150,
    "dpi": 300,
    "background_image": null,
    "overlay_image": null,
    "padding_top": "0.0",
    "padding_right": "0.0",
    "padding_bottom": "0.0",
    "padding_left": "0.0",
    "specs": [
      {
        "id": 4,
        "name": "iPhone 6 手機殼",
        "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕熱轉印特殊防刮抗磨塑料",
        "width": 87,
        "height": 150,
        "dpi": 300,
        "background_image": null,
        "overlay_image": null,
        "padding_top": "0.0",
        "padding_right": "0.0",
        "padding_bottom": "0.0",
        "padding_left": "0.0",
        "__deprecated": "WorkSpec is not longer available"
      }
    ]
  }
}
=end
  def show
  end

=begin
@api {get} /api/product_models/:id/des_images Get the product_model des_images
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup ProductModels
@apiName GetProductModelDescriptionImages
@apiParam {Integer} id product_model id or product_model key
@apiSuccessExample {json} Response-Example:
{
  "des_images": [
    {
      x1: desc_image.x1.url,
      x2: desc_image.x2.url,
      x3: desc_image.url,
    },
    {...}
  ]
}
=end
  def des_images
    @des_images = @product.description_images
  end

  protected

  def find_product_model
    @product = ProductModel.find_by(key: params[:id]) || ProductModel.find(params[:id])
  end
end
