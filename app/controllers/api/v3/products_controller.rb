class Api::V3::ProductsController < ApiV3Controller
  before_action :doorkeeper_authorize!
  expose(:scope) do
    %w(all sellable customizable).include?(params[:scope]) ? params[:scope] : 'all'
  end
  expose(:platform) do
    %w(ios android website).include?(params[:platform]) ? params[:platform] : 'website'
  end
  expose(:available) do
    staff_available? ? 'staff_available' : 'available'
  end

=begin
@api {get} /api/products Get Product list
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Products
@apiName GetProducts
@apiParam {Integer} id product_model id
@apiParam {Boolean} staff get staff available model
@apiParam {String=ios, android, website} platform=website
@apiParam {String=all, sellable, customizable} scope=all
@apiSuccessExample {json} Response-Example:
  {
    "categories" => [
      {
        "id" => 3,
        "key" => "product_category_3",
        "name" => "Name_3",
        "images" => {
          "s80" => "/uploads/product_category/image/4/s80_6d09f665-9415-4567-8379-2ec2b294d967.jpg?v=1460451873",
          "s160" => "/uploads/product_category/image/4/s160_6d09f665-9415-4567-8379-2ec2b294d967.jpg?v=1460451873"
        },
        "models" => [
          {
            "id" => 1,
            "key" => "iphone_1_case",
            "name" => "ProductModelName8",
            "description" => "ProductModelName8 case",
            "prices" => {
              "USD" => 99.9,
              "TWD" => 2999.0,
              "JPY" => 12000.0
            },
            "customized_special_prices" => nil,
            "design_platform" => {
              "ios" => false,
              "android" => false,
              "website" => false
            },
            "customize_platform" => {
              "ios" => false,
              "android" => false,
              "website" => false
            },
            "specs" => []
          }
        ]
      }
    ],
    "meta" => {
      "category_count" => 1,
      "product_model_count" => 1
      "platform" => "website",
      "scope" => "all"
    }
  }
=end
  def index
    options = {
      scope: scope,
      platform: platform,
      available: available
    }
    @presenter = Api::V3::ProductListPresenter.new(options)
    fresh_when(etag: @presenter.etag)
  end
end
