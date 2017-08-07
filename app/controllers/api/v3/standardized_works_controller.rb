=begin
@apiDefine RelatedStandardizedWorkResponse
@apiSuccessExample {json} Response-Example:
{
  "related_works": {
    "series_works": [],
    "designer_works": [
      {
        "id": 3,
        "gid": "Z2lkOi8vY29tbWFuZC1wL1N0YW5kYXJkaXplZFdvcmsvMw",
        "uuid": "fc8d8414-a2fd-11e5-bf60-ac87a30f9d14",
        "name": "蔡淑蓁",
        "user_avatar": {
          "avatar": {
            "url": "http://commandp.dev/uploads/designer/avatar/2/aaa25a24142d9c925c.jpg?v=1439974832"
          }
        },
        "user_id": 2,
        "order_image": {
          "thumb": "http://commandp.dev/media/vVg==--0743fb8b852673cd441fb0eb330ef459ef09ae8f.png",
          "share": "http://commandp.dev/media/--f7ec069381f65d51623b6e5497cfd3fa2d1d022c.png",
          "sample": "http://commandp.dev/media--c342baf524fadc2f4fcba77819a50180b26d2f57.png",
          "normal": "http://commandp.dev/uploads/preview/image/305/logo.png?v=1450165934"
        },
        "gallery_images": [
          {
            "normal": "http://commandp.dev/uploads/preview/image/305/logo.png?v=1450165934",
            "thumb": "http://commandp.dev/media/B==--0743fb8b852673cd441fb0eb330ef459ef09ae8f.png",
            "key": "order-image",
            "url": "http://commandp.dev/uploads/preview/image/305/logo.png?v=1450165934",
            "image_url": "http://commandp.dev/uploads/preview/image/305/logo.png?v=1450165934",
            "position": null
          }
        ],
        "original_prices": {
          "TWD": 899,
          "USD": 29.95,
          "JPY": 3480,
          "HKD": 229
        },
        "prices": {
          "TWD": 899,
          "USD": 29.95,
          "JPY": 3480,
          "HKD": 229
        },
        "user_display_name": "囧哥",
        "wishlist_included": false,
        "slug": null,
        "is_public": true,
        "user_avatars": {
          "s35": "http://commandp.dev/media/BAhbCUkiH2d.jpg",
          "s154": "http://commandp.dev/media/BAhbCUkiH2==--33899aad6aae3967c8c66c92bbc81dc948345409.jpg"
        },
        "spec": {
          "id": 6,
          "name": "iPhone 5s/5 手機殼",
          "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 12.5 g\r\n- 超薄 0.7 mm\r\n- 100% 密合你的手機",
          "width": 84,
          "height": 150,
          "dpi": 300,
          "background_image": null,
          "overlay_image": null,
          "padding_top": "0.0",
          "padding_right": "0.0",
          "padding_bottom": "0.0",
          "padding_left": "0.0",
          "__deprecated": "WorkSpec is not longer available"
        },
        "model": {
          "id": 6,
          "key": "iphone_5_cases",
          "name": "iPhone 5s/5 手機殼",
          "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 12.5 g\r\n- 超薄 0.7 mm\r\n- 100% 密合你的手機",
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
          "width": 84,
          "height": 150,
          "dpi": 300,
          "background_image": null,
          "overlay_image": null,
          "padding_top": "0.0",
          "padding_right": "0.0",
          "padding_bottom": "0.0",
          "padding_left": "0.0"
        },
        "product": {
          "id": 6,
          "key": "iphone_5_cases",
          "name": "iPhone 5s/5 手機殼",
          "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n- 超輕 12.5 g\r\n- 超薄 0.7 mm\r\n- 100% 密合你的手機\r\n- 熱轉印特殊防刮抗磨塑料",
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
          "width": 84,
          "height": 150,
          "dpi": 300,
          "background_image": null,
          "overlay_image": null,
          "padding_top": "0.0",
          "padding_right": "0.0",
          "padding_bottom": "0.0",
          "padding_left": "0.0"
        },
        "category": {
          "id": 5,
          "key": "case",
          "name": "手機殼"
        },
        "featured": false,
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
      }
    ],
    "recommend_works": []
  },
  "meta": {
    "series_count": 0,
    "designer_count": 1,
    "recommend_count": 0
  }
}
=end

=begin
@apiDefine StandardizedWorkResponse
@apiSuccessExample {json} Response-Example:
{
  "work": {
    "id": 6,
    "gid": "Z2lkOi8vY29tbWFuZC1wL1N0YW5kYXJkaXplZFdvcmsvNg",
    "uuid": "dddaf6b4-ba8b-11e5-965b-ac87a30f9d14",
    "name": "athletes",
    "user_avatar": {
      "avatar": {
        "url": "http://commandp.dev/uploads/designer/avatar/2/a496.jpg?v=1439974832"
      }
    },
    "user_id": 2,
    "order_image": {
      "thumb": "http://commandp.dev/media/BAhbCUk==--63fc26615e90abcc505d1fd8d28187519f917826.png",
      "share": "http://commandp.dev/media/BA%2FRpdW--d52d2d4910d75292cdd5b6f1b3798b8fd9b47d63.png",
      "sample": "http://commandp.dev/media/%2FRpdW--95b23816b12af5734a09ad44ac64b333ffebe61d.png",
      "normal": "http://commandp.dev/uploads/preview/image/315/order-image20160114-2155-ye7kkh.png?v=1452754559"
    },
    "gallery_images": [
      {
        "normal": "http://commandp.dev/uploads/preview/image/315/order-image20160114-2155-ye7kkh.png?v=1452754559",
        "thumb": "http://commandp.dev/media/==--63fc26615e90abcc505d1fd8d28187519f917826.png",
        "key": "order-image",
        "url": "http://commandp.dev/uploads/preview/image/315/order-image20160114-2155-ye7kkh.png?v=1452754559",
        "image_url": "http://commandp.dev/uploads/preview/image/315/order-imag60114-2155-ye7kkh.png?v=1452754559",
        "position": null
      }
    ],
    "original_prices": {
      "USD": 10,
      "HKD": 70,
      "TWD": 300,
      "JPY": 1000,
      "CNY": 80
    },
    "prices": {
      "USD": 10,
      "HKD": 70,
      "TWD": 300,
      "JPY": 1000,
      "CNY": 80
    },
    "user_display_name": "囧哥",
    "wishlist_included": false,
    "slug": "athletes-b55064f4-8870-48ef-b2f3-fcd8365177f2",
    "is_public": false,
    "user_avatars": {
      "s35": "http://commandp.dev/media/BA=--b57885d70f094fba4b4687d54c3dc2295d31602f.jpg",
      "s154": "http://commandp.dev/media/ad==--33899aad6aae3967c8c66c92bbc81dc948345409.jpg"
    },
    "spec": {
      "id": 22,
      "name": "金屬貼紙",
      "description": "PP 合成紙材質，主成份為聚丙烯塑膠。\r\n 尺寸上，實際張數依設計而有不同。",
      "width": 262.21,
      "height": 191.09,
      "dpi": 300,
      "background_image": null,
      "overlay_image": null,
      "padding_top": "",
      "padding_right": "",
      "padding_bottom": "",
      "padding_left": "",
      "__deprecated": "WorkSpec is not longer available"
    },
    "model": {
      "id": 22,
      "key": "sticker_metal",
      "name": "金屬貼紙",
      "description": "PP 合成紙材質， 尺寸上，實際張數依設計而有不同。",
      "prices": {
        "USD": 10,
        "HKD": 70,
        "TWD": 300,
        "JPY": 1000,
        "CNY": 80
      },
      "customized_special_prices": null,
      "design_platform": {
        "ios": true,
        "android": false,
        "website": true
      },
      "customize_platform": {
        "ios": false,
        "android": false,
        "website": false
      },
      "placeholder_image": null,
      "width": 262.21,
      "height": 191.09,
      "dpi": 300,
      "background_image": null,
      "overlay_image": null,
      "padding_top": "",
      "padding_right": "",
      "padding_bottom": "",
      "padding_left": ""
    },
    "product": {
      "id": 22,
      "key": "sticker_metal",
      "name": "金屬貼紙",
      "description": "PP 合成紙材質，主成份為聚 尺寸上，實際張數依設計而有不同。",
      "prices": {
        "USD": 10,
        "HKD": 70,
        "TWD": 300,
        "JPY": 1000,
        "CNY": 80
      },
      "customized_special_prices": null,
      "design_platform": {
        "ios": true,
        "android": false,
        "website": true
      },
      "customize_platform": {
        "ios": false,
        "android": false,
        "website": false
      },
      "placeholder_image": null,
      "width": 262.21,
      "height": 191.09,
      "dpi": 300,
      "background_image": null,
      "overlay_image": null,
      "padding_top": "",
      "padding_right": "",
      "padding_bottom": "",
      "padding_left": ""
    },
    "category": {
      "id": 7,
      "key": "sticker",
      "name": "貼紙"
    },
    "featured": false,
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
  }
}
=end
class Api::V3::StandardizedWorksController < ApiV3Controller
  include SearchSupport
  before_action :doorkeeper_authorize!
  before_action :search_work, only: :index
  before_action :find_standardized_work, except: [:index]

=begin
@api {get} /api/standardized_works Get standardized work list
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup StandardizedWorks
@apiName GetStandardizedWorkList
@apiParam {String} [query] key word to search
@apiParam {String} [user_name] user name
@apiParam {Integer} [category_id] category_id
@apiParam {String} [product_key] product_model_key
@apiParam {Integer} [model_id] model id
@apiParam {String} [tag] tag text
@apiParam {String} [tag_name] tag name
@apiParam {String} [collection_name] collection name
@apiParam {String="random", "new", "popular", "price_asc", "price_desc", "recommend"} [sort] sort type
@apiParam {Integer} [page] page number
@apiParam {Integer} [per_page] works count in a single page
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

=begin
@api {get} /api/standardized_works/:id/related Get the related works of a given standardized work
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup StandardizedWorks
@apiName GetRelatedStandardizedWork
@apiParam {String} id standardized_work's uuid
@apiParam {Integer} series_count the count of the same 'series' standardized_work
@apiParam {Integer} designer_count the count of the same 'designer' standardized_work
@apiParam {Integer} recommend_count the count of recommend standardized_work
@apiUse RelatedStandardizedWorkResponse
=end

  def related
    respond_to do |format|
      format.json { render 'api/v3/works/related' }
      format.protobuf { send_data Api::V3::StandardizedWorkRelatedBuf.new(@work, params).to_pb.inspect }
    end
  end

=begin
@api {get} /api/standardized_works/:id Get the standardized work info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup StandardizedWorks
@apiName GetStandardizedWork
@apiParam {String} id standardized_work's uuid
@apiUse StandardizedWorkResponse
=end

  def show
    impressionist(@work)
    render 'api/v3/works/show'
  end

=begin
@api {patch} /api/standardized_works/:id/touch increase the standardized work impressions_count
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup StandardizedWorks
@apiName TouchStandardizedWork
@apiParam {String} id standardized_work's uuid
@apiSuccessExample {json} Success-Response:
  {
    "status": "success"
  }
=end
  def touch
    impressionist(@work)
    render json: { status: 'success' }
  end

  private

  def find_standardized_work
    work = StandardizedWork.non_store.find_by(uuid: params[:id]) || StandardizedWork.non_store.find_by!(slug: params[:id])
    @work = Pricing::ItemableDecorator.new(work)
  end

  def work_class
    StandardizedWork
  end
end
