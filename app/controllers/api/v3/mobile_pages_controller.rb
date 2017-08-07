class Api::V3::MobilePagesController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :init_mobile_page, except: :preview

=begin
@api {get} /api/mobile_pages Get mobile pages list
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup MobilePage
@apiName GetMobilePagesList
@apiSuccessExample {json} Response-Example:
{
    "mobile_pages": [{
        "id": 1,
        "key": "home",
        "begin_at": "2015-11-01T11:38:00.000+08:00",
        "close_at": "2015-12-01T11:38:00.000+08:00",
        "page_type": "homepage"
    }, {
        "id": 2,
        "key": "campaign",
        "begin_at": "2015-11-17T16:55:00.000+08:00",
        "close_at": "2015-11-20T16:55:00.000+08:00",
        "page_type": "campaign_subject"
    }]
}

=end
  def index
    @mobile_pages = @mobile_page.page(params[:page])
  end

=begin
@apiDefine MobilePageResponse
@apiSuccessExample {String} Response 說明:
  page_type 分成 homepage(只會有一個), campaign_subject, campaign_limited_time, campaign_limited_quantity
@apiSuccessExample {json} Response-Example:
{
  "mobile_page": {
    "id": 1,
    "key": "home",
    "begin_at": "2015-11-17T16:55:00.000+08:00",
    "close_at": "2015-11-20T16:55:00.000+08:00",
    "page_type": "campaign_subject",
    "components": [{
      "type": "kv",
      "position": 1,
      "items": [{
        "link": "123",
        "image": {
          "thumb": "http://commandp.dev/media/BAhbCUkiKmdpZDovL2NvbW1hbmQtcC9TdWJNb2JpbGVDb21wb25lbnQvNTAGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB63xSlY=--b46e672d30354faff6450f6f2d5016fdbf9038a6.png",
          "normal": "http://commandp.dev/uploads/sub_mobile_component/image/50/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447752109",
          "large": "http://commandp.dev/uploads/sub_mobile_component/image/50/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447752109"
        }
      }, {
        "link": "456",
        "image": {
          "thumb": "http://commandp.dev/media/BAhbCUkiKmdpZDovL2NvbW1hbmQtcC9TdWJNb2JpbGVDb21wb25lbnQvNTEGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB63xSlY=--fbc53b0de671a165c00063442f0c2532e9b848e5.png",
          "normal": "http://commandp.dev/uploads/sub_mobile_component/image/51/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447752109",
          "large": "http://commandp.dev/uploads/sub_mobile_component/image/51/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447752109"
        }
      }]
    }, {
      "type": "ticker",
      "position": 2,
      "title": "最新消息",
      "contents": [
        "週末熱賣８折",
        "１１１１全館１折起"
      ]
    }, {
      "type": "product_line",
      "position": 3,
      "products": [
        " create",
        "canvas",
        "sticker",
        "mugs"
      ]
    }, {
      "type": "campaign_section",
      "position": 4,
      "section_title": "主題限定",
      "section_color": "#b82727",
      "campaigns": [{
        "image": {
          "thumb": "http://commandp.dev/media/BAhbCUkiKmdpZDovL2NvbW1hbmQtcC9TdWJNb2JpbGVDb21wb25lbnQvNjEGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrBzD1SlY=--a08e137c9463e25123c7da27b0b76654378ee982.png",
          "normal": "http://commandp.dev/uploads/sub_mobile_component/image/61/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447753008",
          "large": "http://commandp.dev/uploads/sub_mobile_component/image/61/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447753008"
        },
        "page_type": "campaign_subject",
        "title": "campaign title",
        "description": "全系列產品  ＄９９９起",
        "action_text": "馬上買",
        "key": "home",
        "link": "mobile_page?key=home",
        "begin_at": "2015-11-17T16:55:00.000+08:00",
        "close_at": "2015-11-20T16:55:00.000+08:00",
        "limited_count": 0
      }]
    }]
  }
}

@apiSuccessExample {json} Component-kv:
{
  "type": "kv",
  "position": 1,
  "items": [{
    "link": "123",
    "image": {
        "thumb": "http://commandp.dev/media/BAhbCUkiKmdpZDovL2NvbW1hbmQtcC9TdWJNb2JpbGVDb21wb25lbnQvNTAGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB63xSlY=--b46e672d30354faff6450f6f2d5016fdbf9038a6.png",
        "normal": "http://commandp.dev/uploads/sub_mobile_component/image/50/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447752109",
        "large": "http://commandp.dev/uploads/sub_mobile_component/image/50/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447752109"
    }
  }, {
    "link": "456",
    "image": {
        "thumb": "http://commandp.dev/media/BAhbCUkiKmdpZDovL2NvbW1hbmQtcC9TdWJNb2JpbGVDb21wb25lbnQvNTEGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB63xSlY=--fbc53b0de671a165c00063442f0c2532e9b848e5.png",
        "normal": "http://commandp.dev/uploads/sub_mobile_component/image/51/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447752109",
        "large": "http://commandp.dev/uploads/sub_mobile_component/image/51/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447752109"
    }
  }]
}

@apiSuccessExample {json} Component-ticker:
{
    "type": "ticker",
    "position": 2,
    "title": "最新消息",
    "contents": [
        "週末熱賣８折",
        "１１１１全館１折起"
    ]
}

@apiSuccessExample {json} Component-product_line:
{
    "type": "product_line",
    "position": 3,
    "products": [
        " create",
        "canvas",
        "sticker",
        "mugs"
    ]
}

@apiSuccessExample {json} Component-campaign_section:
{
    "type": "campaign_section",
    "position": 4,
    "section_title": "主題限定",
    "section_color": "#b82727",
    "campaigns": [{
        "image": {
            "thumb": "http://commandp.dev/media/BAhbCUkiKmdpZDovL2NvbW1hbmQtcC9TdWJNb2JpbGVDb21wb25lbnQvNjEGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrBzD1SlY=--a08e137c9463e25123c7da27b0b76654378ee982.png",
            "normal": "http://commandp.dev/uploads/sub_mobile_component/image/61/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447753008",
            "large": "http://commandp.dev/uploads/sub_mobile_component/image/61/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447753008"
        },
        "title": "campaign title",
        "description": "全系列產品  ＄９９９起",
        "action_text": "馬上買",
        "key": "home",
        "link": "mobile_page?key=home",
        "begin_at": "2015-11-17T16:55:00.000+08:00",
        "close_at": "2015-11-20T16:55:00.000+08:00",
        "limited_count": 0
    }]
}

@apiSuccessExample {json} Component-products_section:
{
    "type": "products_section",
    "position": 5,
    "section_title": "主題限定",
    "section_color": "#e0531b",
    "product_type": "type_b",
    "background": {
        "thumb": "http://commandp.dev/media/BAhbCUkiJ2dpZDovL2NvbW1hbmQtcC9Nb2JpbGVDb21wb25lbnQvODAGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB0ZWTFY=--cce6439263854cca9fed064ed70eaf355a1285f2.png",
        "normal": "http://commandp.dev/uploads/mobile_component/image/80/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-17_%E4%B8%8B%E5%8D%886.39.41.png?v=1447843398",
        "large": "http://commandp.dev/uploads/mobile_component/image/80/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-17_%E4%B8%8B%E5%8D%886.39.41.png?v=1447843398"
    },
    "products": [{
        "image": {
            "thumb": "http://commandp.dev/media/BAhbCUkiKmdpZDovL2NvbW1hbmQtcC9TdWJNb2JpbGVDb21wb25lbnQvNjMGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB139SlY=--414376cb20a31753a135ce5c92fd15175e52925e.png",
            "normal": "http://commandp.dev/uploads/sub_mobile_component/image/63/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447755101",
            "large": "http://commandp.dev/uploads/sub_mobile_component/image/63/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447755101"
        },
        "gid": "gid://command-p/Work/18797",
        "uuid": "fb00bad6-2aca-11e5-91ea-3c15c2d24fd8",
        "title": "白白馬克杯",
        "description": "",
        "original_price": {
            "TWD": 499,
            "USD": 16.9,
            "JPY": 1780,
            "HKD": 129
        },
        "price": {
            "TWD": 499,
            "USD": 16.9,
            "JPY": 1780,
            "HKD": 129
        },
        "tip_text": "75折",
        "will_sale_text": "即將開賣",
        "on_sale_text": "馬上買",
        "work": {
            "id": 18797,
            "gid": "Z2lkOi8vY29tbWFuZC1wL1dvcmsvMTg3OTc",
            "uuid": "fb00bad6-2aca-11e5-91ea-3c15c2d24fd8",
            "name": "pineapple",
            "user_avatar": {
                "avatar": {
                    "url": "http://commandp.dev/uploads/designer/avatar/6/beach.jpg?v=1439873121"
                }
            },
            "user_id": 6,
            "order_image": {
                "thumb": "http://commandp.dev/media/BAhbCUkiIGdpZDovL2NvbW1hbmQtcC9QcmV2aWV3LzM0MQY6BkVUOgppbWFnZXsGOhJyZXNpemVfdG9fZml0WwdpaWlpbCsH7RimVQ==--0862ce829bdd3cd221093ed0a32bf9d1942bf4a5.jpg",
                "share": "http://commandp.dev/media/BAhbCUkiIGdpZDovL2NvbW1hbmQtcC9QcmV2aWV3LzM0MQY6BkVUOgppbWFnZXsGOhNyZXNpemVfYW5kX3BhZFsHaQKGAWkChgFsKwftGKZV--439c72e9c523851d2de5a8da2f83cd0f2e61e12c.jpg",
                "sample": "http://commandp.dev/media/BAhbCUkiIGdpZDovL2NvbW1hbmQtcC9QcmV2aWV3LzM0MQY6BkVUOgppbWFnZXsGOhRyZXNpemVfdG9fbGltaXRbBzBpAchsKwftGKZV--e2fef6b936e9d99b2ecb063dae85feeb57222876.jpg",
                "normal": "http://commandp.dev/uploads/preview/image/341/order_image20150715-23162-yiizhu.jpg?v=1436948717"
            },
            "gallery_images": [{
                "normal": "http://commandp.dev/uploads/preview/image/341/order_image20150715-23162-yiizhu.jpg?v=1436948717",
                "thumb": "http://commandp.dev/media/BAhbCUkiIGdpZDovL2NvbW1hbmQtcC9QcmV2aWV3LzM0MQY6BkVUOgppbWFnZXsGOhJyZXNpemVfdG9fZml0WwdpaWlpbCsH7RimVQ==--0862ce829bdd3cd221093ed0a32bf9d1942bf4a5.jpg"
            }, {
                "normal": "http://commandp.dev/uploads/preview/image/342/order_image20150715-23162-16systq.jpg?v=1436948717",
                "thumb": "http://commandp.dev/media/BAhbCUkiIGdpZDovL2NvbW1hbmQtcC9QcmV2aWV3LzM0MgY6BkVUOgppbWFnZXsGOhJyZXNpemVfdG9fZml0WwdpaWlpbCsH7RimVQ==--da387fbb0c088eb7214ebaecf886a822ee442926.jpg"
            }],
            "prices": {
                "TWD": 499,
                "USD": 16.9,
                "JPY": 1780,
                "HKD": 129
            },
            "user_display_name": "HappySummer",
            "wishlist_included": false,
            "slug": "pineapple-1b50c629-529c-442f-a62a-6f879d736433",
            "is_public": true,
            "user_avatars": {
                "s35": "http://commandp.dev/media/BAhbCUkiH2dpZDovL2NvbW1hbmQtcC9EZXNpZ25lci82BjoGRVQ6C2F2YXRhcnsGOhNyZXNpemVfdG9fZmlsbFsHaShpKGwrB2G40lU=--d3004ef1a9a1d37257776f7a6789eadf47e71d23.jpg",
                "s154": "http://commandp.dev/media/BAhbCUkiH2dpZDovL2NvbW1hbmQtcC9EZXNpZ25lci82BjoGRVQ6C2F2YXRhcnsGOhNyZXNpemVfdG9fZmlsbFsHaQGaaQGabCsHYbjSVQ==--526ea08abb4bb1fd75f9f8f24809f136f8f6442c.jpg"
            },
            "spec": {
                "id": 37,
                "name": "馬克杯",
                "description": "發揮創意，打造屬於你或你們的馬克杯。\r\n想要擁有自己獨有設計的杯款，或與另一半、家人、朋友們成對的紀念對杯，\r\n現在上傳最愛的圖片加上你的創意，專屬你們的紀念 commandp 我印 幫你印！\r\n\r\n- 熱昇華壓燙技術，色彩鮮明持久\r\n- 可使用於洗碗機及微波爐\r\n\r\n材質：陶瓷\r\n尺寸：高 95mm，直徑 75mm (不含手把)",
                "width": 210,
                "height": 85,
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
                "id": 37,
                "key": "mugs",
                "name": "馬克杯"
            },
            "category": {
                "id": 2,
                "key": "mug",
                "name": "馬克杯"
            }
        }
    }]
}

@apiSuccessExample {json} Component-media_section:
{
    "type": "media_section",
    "position": 6,
    "items": [{
        "image": {
            "thumb": "http://commandp.dev/media/BAhbCUkiKmdpZDovL2NvbW1hbmQtcC9TdWJNb2JpbGVDb21wb25lbnQvNjUGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB139SlY=--f38eba92207eba4b42aa4229b94b24a0099f567c.png",
            "normal": "http://commandp.dev/uploads/sub_mobile_component/image/65/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-13_%E4%B8%8B%E5%8D%886.51.10.png?v=1447755101",
            "large": "http://commandp.dev/uploads/sub_mobile_component/image/65/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-13_%E4%B8%8B%E5%8D%886.51.10.png?v=1447755101"
        },
        "title": "單身貼紙熱賣上市",
        "content": "一起用我印製做你的單身貼",
        "media_type": "A",
        "media_url": "https://www.youtube.com/watch?v=5oJCPcjeku8",
        "action_text": "開始印",
        "action_type": "create",
        "action_target": "product_model",
        "action_key": "iphone_6_cases"
    }]
}

@apiSuccessExample {json} Component-create_section:
{
    "type": "create_section",
    "position": 7,
    "background": {
        "thumb": "http://commandp.dev/media/BAhbCUkiJ2dpZDovL2NvbW1hbmQtcC9Nb2JpbGVDb21wb25lbnQvNjYGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB8kBS1Y=--57ec168585e04bc6d15f357237ef09445218020c.png",
        "normal": "http://commandp.dev/uploads/mobile_component/image/66/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-13_%E4%B8%8B%E5%8D%886.51.10.png?v=1447756233",
        "large": "http://commandp.dev/uploads/mobile_component/image/66/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-13_%E4%B8%8B%E5%8D%886.51.10.png?v=1447756233"
    },
    "title": "客製化商品",
    "items": [{
        "image": {
            "thumb": "http://commandp.dev/media/BAhbCUkiKmdpZDovL2NvbW1hbmQtcC9TdWJNb2JpbGVDb21wb25lbnQvNjcGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB8kBS1Y=--7f9c7757dc07bfe01c818e1328ea956b61949828.png",
            "normal": "http://commandp.dev/uploads/sub_mobile_component/image/67/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447756233",
            "large": "http://commandp.dev/uploads/sub_mobile_component/image/67/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-16_%E4%B8%8A%E5%8D%8811.15.45.png?v=1447756233"
        },
        "title": "手機殼",
        "action_type": "create",
        "action_target": "product_category",
        "action_key": "mug"
    }]
}

@apiSuccessExample {json} Component-description_section:
{
    "type": "description_section",
    "position": 8,
    "items": [{
        "title": "Title",
        "description": "Desc"
    }, {
        "title": "Title2",
        "description": "Desc 2"
    }]
}

@apiSuccessExample {json} Component-download_section:
{
    "type": "download_section",
    "position": 9,
    "background": {
        "thumb": "http://commandp.dev/media/BAhbCUkiJ2dpZDovL2NvbW1hbmQtcC9Nb2JpbGVDb21wb25lbnQvODAGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB0ZWTFY=--cce6439263854cca9fed064ed70eaf355a1285f2.png",
        "normal": "http://commandp.dev/uploads/mobile_component/image/80/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-17_%E4%B8%8B%E5%8D%886.39.41.png?v=1447843398",
        "large": "http://commandp.dev/uploads/mobile_component/image/80/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-17_%E4%B8%8B%E5%8D%886.39.41.png?v=1447843398"
    },
    "title": "dddd",
    "items": [{
        "image": {
            "thumb": "http://commandp.dev/media/BAhbCUkiKmdpZDovL2NvbW1hbmQtcC9TdWJNb2JpbGVDb21wb25lbnQvNzIGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB2kES1Y=--1f9c2b8556ea755ec166804604290f7479af1b50.png",
            "normal": "http://commandp.dev/uploads/sub_mobile_component/image/72/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-17_%E4%B8%8B%E5%8D%886.39.41.png?v=1447756905",
            "large": "http://commandp.dev/uploads/sub_mobile_component/image/72/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-17_%E4%B8%8B%E5%8D%886.39.41.png?v=1447756905"
        },
        "title": "Boom",
        "download_url": "",
        "action_type": "create",
        "action_target": "product_model",
        "action_key": "iphone_6_cases"
    }]
}

@apiSuccessExample {json} Component-tab_section:
{
    "type": "tab_section",
    "position": 10,
    "create_text": "開始印",
    "shop_text": "逛商城",
    "download_text": "下載素材"
}

@apiSuccessExample {json} Component-campaign_background:
{
    "type": "campaign_background",
    "position": 11,
    "thumb": "http://commandp.dev/media/BAhbCUkiJ2dpZDovL2NvbW1hbmQtcC9Nb2JpbGVDb21wb25lbnQvNzcGOgZFVDoKaW1hZ2V7BjoScmVzaXplX3RvX2ZpdFsHaWlpaWwrB5xQTFY=--4f92f2671b5aba4ba01a69b1b9af7cf960061e52.png",
    "normal": "http://commandp.dev/uploads/mobile_component/image/77/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-18_%E4%B8%8B%E5%8D%884.33.44.png?v=1447841948",
    "large": "http://commandp.dev/uploads/mobile_component/image/77/%E8%9E%A2%E5%B9%95%E5%BF%AB%E7%85%A7_2015-11-18_%E4%B8%8B%E5%8D%884.33.44.png?v=1447841948"
}
=end

=begin
@api {get} /api/mobile_pages/:key  Get mobile page
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup MobilePage
@apiName GetMobilePage
@apiParam {String} key ex: home
@apiUse MobilePageResponse
=end
  def show
    @mobile_page = @mobile_page.find_by(key: params[:key])
    @mobile_page = default_mobile_page.find_by!(key: params[:key]) unless @mobile_page
    fresh_when(etag: @mobile_page, last_modified: @mobile_page.updated_at)
  end

=begin
@api {get} /api/mobile_pages/:key/preview  Get mobile page preview
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup MobilePage
@apiName GetMobilePagePreview
@apiParam {String} key ex: home
@apiUse MobilePageResponse
=end

  # preview 不需要cache
  def preview
    mobile_page = MobilePage.find_by(key: params[:key])
    @mobile_page_preview = MobilePagePreview.includes(:mobile_components).find_by(mobile_page_id: mobile_page.id)
  end

  private

  def init_mobile_page
    country_code = params[:country_code] || current_country_code
    country_code = MobilePage.mapping_country_code(country_code)
    @mobile_page = MobilePage.enabled.where(country_code: country_code).includes(:mobile_components)
  end

  def default_mobile_page
    MobilePage.enabled.where(country_code: MobilePage::COUNTRY_CODE_DEFAULT).includes(:mobile_components)
  end
end
