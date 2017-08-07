class Api::V2::ProductsController < ApiV2Controller
  expose(:scope) do
    %w(all sellable customizable).include?(params[:scope]) ? params[:scope] : 'all'
  end
  expose(:platform) do
    params[:platform] if %w(ios android website).include?(params[:platform])
  end
  expose(:available) do
    staff_available? ? 'staff_available' : 'available'
  end
  expose(:categories, model: :product_category) do
    products = ProductModel.includes(:translations, :currencies, category: :translations).send(available)
    if platform.present?
      products = products.store_on_platform(platform, scope)
                         .platform_order_with_category(platform)
    end
    products.group_by(&:category).to_a
  end
=begin
@api {get} /api/products Get all available product category and models
@apiGroup Products
@apiName GetProducts
@apiParam {Boolean} staff get staff available model
@apiParam {String=ios, android, website} platform=nil
@apiParam {String=all, sellable, customizable} scope=all
@apiVersion 2.0.0
@apiSuccessExample {json} Success-Response:
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
      "product_model_count" => 1,
      "platform" => 'website'
      "scope" => 'all'
    }
  }
=end
  def index
    render 'api/v2/products/index'
    fresh_when(etag: categories)
  end
end
