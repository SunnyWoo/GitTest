=begin
@apiDefine ReviewList
@apiParam {Integer} reviews_count the number of reviews to get back
@apiParam {Time} reviews_before reviews created before the time get back
@apiParam {String} reviews_order sort type
@apiSuccessExample {json} Response-Example:
  {
    "reviews": [
      {
        "user": {
          "id": 1,
          "name": "",
          "avatars": {
            "s35": "http://commandp.dev/uploads/user/avatar/1/s35_03.jpg?v=1454129975",
            "s114": "http://commandp.dev/uploads/user/avatar/1/asdas.jpg?v=1454129975",
            "s154": "http://commandp.dev/uploads/user/avatar/1/s154_0.jpg?v=1454129975"
          },
          "avatar_url": "http://commandp.dev/uploads/user/avatar/1/03.jpg?v=1454129975",
          "background_url": "http://commandp.dev/assets/my_gallery/img_gallery_kv-2.png?v=1454129975",
          "gender": "male",
          "location": "",
          "works_count": 15,
          "role": "normal"
        },
        "user_id": 1,
        "user_name": "",
        "user_avatar": "http://commandp.dev/uploads/user/avatar/1/03.jpg?v=1454129975",
        "body": "甘蔗紅茶 半糖去冰！",
        "star": 4,
        "created_at": "2016-02-02T16:25:20.446+08:00"
      }
    ],
    "meta": {
      "reviews_count": 1
    }
  }
=end

=begin
@apiDefine CreateReviews
@apiParam {Integer} work_id work's uuid or work's slug
@apiParam {String} body review content
@apiParam {Integer} star review star count
@apiSuccessExample {json} Response-Example:
  {
    "review": {
      "user": {
        "id": 1,
        "name": "必格納母",
        "avatars": {
          "s35": "http://commandp.dev/uploads/user/avatar/1/.jpg?v=1451364085",
          "s114": "http://commandp.dev/uploads/user/avatar/1/s114_.jpg?v=1451364085",
          "s154": "http://commandp.dev/uploads/user/avatar/1/s154_.jpg?v=1451364085"
        },
        "avatar_url": "http://commandp.dev/uploads/user/avatar/1/.jpg?v=1451364085",
        "background_url": "http://commandp.dev/assets/my_gallery/img_gallery_kv-2.png?v=1451364085",
        "gender": "male",
        "location": "Makkah Al Mukarramah, Makkah, Saudi Arabia",
        "works_count": 15,
        "role": "normal"
      },
      "user_id": 1,
      "user_name": "LALA",
      "user_avatar": "http://commandp.dev/uploads/user/avatar/1/.jpg?v=1451364085",
      "body": "霸王寒流來襲，取名字的是WT嗎?",
      "star": 3,
      "created_at": "2016-01-25T12:56:55.018+08:00"
    }
  }
=end
class Api::V3::ReviewsController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :find_work
  before_action :check_user, only: :create

=begin
@apiName WorkReviewList
@api {get} /api/works/:work_id/reviews Get the work's reviews
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Reviews
@apiUse ReviewList
@apiParam {Integer} work_id work's uuid or work's slug
=end

=begin
@apiName StandardizedWorkReviewList
@api {get} /api/standardized_works/:standardized_work_id/reviews Get the standardized_work's reviews
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Reviews
@apiUse ReviewList
@apiParam {Integer} standardized_work_id standardized_work's uuid or work's slug
=end
  def index
    filter_reviews
    order_reviews
    limit_reviews
  end

=begin
@api {post} /api/works/:work_id/reviews Create the work's review
@apiName CreatedWorkReview
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Reviews
@apiUse CreateReviews
=end

=begin
@api {post} /api/standardized_works/:standardized_work_id/reviews Create the standardized_work's review
@apiName CreateStandardizedWorkReview
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Reviews
@apiUse CreateReviews
=end
  def create
    @review = @work.reviews.create!(review_permitted_params.merge(user: current_user))
    render :show
  end

  protected

  def find_work
    @work = case
            when params[:work_id]
              Work.find_by(uuid: params[:work_id]) || Work.find_by!(slug: params[:work_id])
            when params[:standardized_work_id]
              StandardizedWork.find_by(uuid: params[:standardized_work_id]) ||
              StandardizedWork.find_by!(slug: params[:standardized_work_id])
            end
  end

  def review_permitted_params
    params.permit(:body, :star)
  end

  def filter_reviews
    @reviews = if params[:reviews_before].present?
                 @work.reviews.earlier(params[:reviews_before])
               else
                 @work.reviews
               end
  end

  def order_reviews
    return if params[:reviews_order] == 'asc'
    @reviews = @reviews.unscope(:order).ordered_desc
  end

  def limit_reviews
    return unless params[:reviews_count].present?
    @reviews = @reviews.limit(params[:reviews_count].to_i)
  end
end
