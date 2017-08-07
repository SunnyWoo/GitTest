class Api::V3::My::WishlistsController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user
  before_action :find_work_and_wishlist, except: [:show]

=begin
@api {get} /api/my/wishlists Get the content of the current user wishlist
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/WishLists
@apiName GetUserWishlist
@apiParamExample {json} Response-Example:
  {
    'wishlist' {
      'id': 1,
      'user_id': 1,
      'works': [
        {
          'uuid': '9f75e090-ab51-11e4-99ac-ac87a30f9d14',
          'name': 'My Design',
          'description': 'User the force, Luke',
          'model_id': 4,
          'model_name': 'iPhone 6 Cases',
          'order_image': 'http://commandp.dev/uploads/preview/image/13/order_image201...jpg?v=1427776213'
        }
      ]
    }
  }
=end
  def show
    @wishlist = current_user.wishlist
    render 'api/v3/wishlists/show'
  end

=begin
@api {post} /api/my/wishlists/:id Add one work to a wishlish of the current user
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/WishLists
@apiName AddWork
@apiParam {Integer} id the work id
@apiParamExample {json} Response-Example:
  {
    'status': 'success'
  }
=end
  def create
    @wishlist.works << @work
    @wishlist.save!
    render json: { message: :success }, status: :ok
  end

=begin
@api {delete} /api/my/wishlists/:id Delete one work from the wishlist of the current user
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup My/WishLists
@apiName DeleteWork
@apiParam {Integer} id the work id
@apiParamExample {json} Response-Example:
  {
    'status': 'success'
  }
=end
  def destroy
    @wishlist.works.destroy(@work)
    render json: { status: :success }, status: :ok
  end

  protected

  def find_work_and_wishlist
    @work = Work.find(params[:id])
    @wishlist = current_user.wishlist || current_user.build_wishlist
  end
end
