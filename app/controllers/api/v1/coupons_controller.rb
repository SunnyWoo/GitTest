class Api::V1::CouponsController < ApiController
  # Coupon validate
  #
  # Url : /api/validate
  #
  # RESTful : GET
  #
  # Get Example
  #   /api/validate?code=WELCOME6
  #
  # Return Example
  #  {
  #    "title": "hello coupon",
  #    "expired_at": "2015-10-16",
  #    "is_used": false,
  #    "currencies": [
  #      {
  #        "name": "U.S. Dollar",
  #        "code": "USD",
  #        "price": 5
  #      }
  #    ]
  #  }
  #
  # @param request code [String] code
  #
  # @return [JSON] status 200
  #
  def validate
    return render json: { status: 'Error', message: 'Missing code parameter' } if params[:code].nil?
    coupon = Coupon.find_coupon(params[:code].upcase.strip)
    if coupon.present?
      if coupon.can_use?(current_user)
        render json: coupon, root: false
      else
        render json: { status: 'Error', message: coupon.errors.full_messages }
      end
    else
      render json: { status: 'Error', message: "Code isn't exist" }
    end
  end
end
