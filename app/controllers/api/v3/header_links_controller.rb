class Api::V3::HeaderLinksController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/header_links Get Header links
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup HeaderLinks
@apiName GetHeaderLinks
@apiSuccessExample {json} Response-Example:
  {
     "header_links": [{
       "title": "开始印",
       "href": "",
       "blank": false,
       "dropdown": true,
       "colunms": [
         {
           "links": [
             {
               "title": "iPhone 6 手机壳",
               "spec_id": null,
               "href": "",
               "type": "text",
               "blank": false,
               "tags": [
                 {
                   "title": "热门",
                   "class": "primary,success,warning,danger,default,info"
                 }
               ]
             },
             {
               "title": "华为 R6 手机壳",
               "href": "http://commandp.com.cn",
               "blank": false,
               "type": "url"
               "tags": []
             },
             {
               "title": "留住夏天的尾巴",
               "href": "",
               "blank": false,
               "spec_id": 16,
               "type": "create"
               "tags": []
             }
           ]
         }
       ]
     }, ...]
   }
=end
  def index
    @header_links = HeaderLink.root
  end
end
