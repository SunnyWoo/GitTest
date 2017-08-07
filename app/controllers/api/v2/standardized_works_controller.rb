class Api::V2::StandardizedWorksController < ApiV2Controller
  include SearchSupport
  before_action :search_work, only: :index

=begin
@api {get} /api/standardized_works Get standardized work list
@apiVersion 2.0.0
@apiGroup StandardizedWorks
@apiName GetStandardizedWorkList
@apiParam {String} query key word to search
@apiParam {String} user_name user name
@apiParam {Integer} category_id category_id
@apiParam {String} product_key product_model_key
@apiParam {Integer} model_id model id
@apiParam {String} tag tag text
@apiParam {String} tag_name tag name
@apiParam {String} collection_name collection name
@apiParam {String="random", "new", "popular", "price_asc", "price_desc", "recommend"} sort sort type
@apiParam {Integer} page page number
@apiParam {Integer} per_page works count in a single page
@apiSuccessExample {json} Response-Example:
  {
    "standardized_works": [{
      "id": 1,
      "gid": "Z2lkOi8vY29tbWFuZC1wL1N0YW5kYXJkaXplZFdvcmsvMQ",
      "uuid": "5d75cf82-8f99-4b41-9820-42ffc35d2188",
      "name": "The Great Work #1",
      "user_avatar": {
        "s35": "/assets/img_fbdefault.png?v=1448019087",
        "s154": "/assets/img_fbdefault.png?v=1448019087"
      },
      "user_id": 1,
      "order_image": {
        "thumb": "http://commandp.dev/media/BAhbCUkiH2dpZDovL2NvbW1hbmQtcC9QcmV...jpg",
        "share": "http://commandp.dev/media/BAhbCUkiH2dpZDovL2NvbW1hbmQtcC9Qcm....jpg",
        "sample": "http://commandp.dev/media/BAhbCUkiH2dpZDovL2NvbW1hbmQtcC9QcmV2..jpg",
        "normal": "http://commandp.dev/uploads/preview/im-5210-13i35lt.jpg?v=1427776213"
      },
      "gallery_images": [{
        "normal": "http://commandp.dev/media/BAhbCUkiH2dpZDovL2NvbW1hbmQtcC9QcmV...jpg",
        "thumb": "http://commandp.dev/media/BAhbCUkiH2dpZDovL2NvbW1hbmQtcC9QcmV...jpg"
      }, ...],
      "prices": {
        "USD": 99.9,
        "TWD": 2999.0,
        "JPY": 12000.0,
        "CNY": 600.0,
        "HKD": 500.0
      },
      "original_prices": {
        "USD": 99.9,
        "TWD": 2999.0,
        "JPY": 12000.0,
        "CNY": 600.0,
        "HKD": 500.0
      },
      "user_display_name": "User Name",
      "wishlist_included": false,
      "slug": "the-great-work-1",
      "featured": false,
      "model": {
        "id": 1,
        "key": "iphone_1_case",
        "name": "ProductModelName8"
      },
      "category": {
        "id": 1,
        "key": "product_category_1",
        "name": "Name_1"
      },
      "tags": [
        {
          "id": 3,
          "name": "tag_1",
          "text": "标签1"
        },
        {
          "id": 6,
          "name": "tag_2",
          "text": "标签2"
        }
      ]
    }],
    "meta": {
      "request_query": {
        "query": "work",
        "sort": "new"
      },
      "current_page_count": 5,
      "current_page": 1,
      "per_page": 5,
      "total_count": 7,
      "total_pages": 2
    }
  }
=end

  def index
    @request_query = params.slice(:query, :model_id, :user_name, :tag,
                                  :sort, :model_key, :category_id)
    render 'api/v3/works/index'
  end

  private

  def work_class
    StandardizedWork
  end
end
