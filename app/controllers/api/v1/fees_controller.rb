class Api::V1::FeesController < ApiController
  # Fee list
  #
  # Url : /api/fees
  #
  # RESTful : GET
  #
  # Get Example
  #   /api/fees
  #
  # Return Example
  #  [
  #    {
  #      "name": "express",
  #      "currencies": [
  #        {
  #          "name": "USD",
  #          "code": "USD",
  #          "price": 6.99
  #        }
  #      ]
  #    },
  #    {
  #      "name": "cash_on_delivery",
  #      "currencies": [
  #        {
  #          "name": "USD",
  #          "code": "USD",
  #          "price": 1
  #        }
  #      ]
  #    }
  #  ]
  #
  # @return [JSON] status 200
  #
  def index
    @fees = Fee.where('name in (?)',BillingProfile.shipping_ways.keys)
    render json: @fees, root: false
    fresh_when(etag: @fees)
  end

  # Shipping fee
  #
  # Url : /api/shipping_fee
  #
  # RESTful : GET
  #
  # Get Example
  #   /api/shipping_fee
  #
  # Return Example
  #   {
  #     "name": "shipping fee",
  #     "currencies": [
  #       {
  #         "name": "USD",
  #         "code": "USD",
  #         "price": 6.99
  #       },
  #       {
  #         "name": "TWD",
  #         "code": "TWD",
  #         "price": 210
  #       }
  #     ]
  #   }
  #
  # @return [JSON] status 200
  #
  def shipping_fee
    @fee = Fee.where(name: '運費').first
    render json: @fee, root: false
    fresh_when(etag: @fee, last_modified: @fee.updated_at)
  end
end
