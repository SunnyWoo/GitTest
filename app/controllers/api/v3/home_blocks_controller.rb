class Api::V3::HomeBlocksController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/home_blocks Get home_block lists
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup HomeBlocks
@apiName GetHomeBlock
@apiSuccessExample {json} Response-Example:
{
  "home_blocks": [
    {
      "id": 1,
      "title": "花的發",
      "template": "collection_2",
      "position": 1,
      "title_translations": {
        "zh-TW": "花的發",
        "zh-CN": "",
        "zh-HK": "",
        "en": "WTF",
        "ja": ""
      },
      "items": [
        {
          "id": 1,
          "block_id": 1,
          "title": "部長很忙",
          "title_translations": {
            "zh-TW": "部長很忙",
            "zh-CN": "",
            "zh-HK": "",
            "en": "secretary is busy",
            "ja": ""
          },
          "subtitle": "部長",
          "subtitle_translations": {
            "zh-TW": "部長",
            "zh-CN": null,
            "zh-HK": null,
            "en": "secretary",
            "ja": null
          },
          "href": "http://zh.wikipedia.org/wiki/%E9%83%A8%E9%95%B7",
          "image": "http://commandp.dev/media/--7a8e6f8c323c8447856db54345c4fbdae06e9c44.jpg",
          "position": 1,
          "pic_translations": {
            "zh-TW": "http://commandp.dev/media/--7a8e6f8c323c8447856db54345c4fbdae06e9c44.jpg",
            "zh-CN": null,
            "zh-HK": null,
            "en": "http://commandp.dev/media/--40a1eb21c5887be2b639fcb5dd0feccf666136ac.png",
            "ja": "http://commandp.dev/media/--bbec4b4655adf3035c97f9de9c4690a0d21ae869.jpg"
          }
        }
      ]
    }
  ]
}
=end
  def index
    @home_blocks = HomeBlock.ordered
    render 'api/v3/home_blocks/index'
  end
end
