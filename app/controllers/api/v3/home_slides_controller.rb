class Api::V3::HomeSlidesController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/home_slides Get home_slide list
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup HomeSlides
@apiName GetHomeSlides
@apiParam {String} set set type
@apiSuccessExample {json} Response-Example:
   {
     "home_slides": [
       {
         "id": 4,
         "set": "default",
         "template": "kv_middle",
         "background": null,
         "slide": "http://commandp.dev/uploads/home_slide/translation/slide/19/132123028_n.jpg?v=1427180814",
         "title": "Yoonaaa",
         "link": "",
         "desc": {
           "title2": "",
           "title3": "",
           "content1": "",
           "content2": "",
           "content3": ""
         },
         "priority": 1
       }
     ]
   }
=end
  def index
    @home_slides = HomeSlide.enabled.where(set: params[:set].to_s)
    render 'api/v3/home_slides/index'
  end
end
