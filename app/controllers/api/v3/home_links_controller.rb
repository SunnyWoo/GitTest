class Api::V3::HomeLinksController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/home_links Get home links
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup HomeLinks
@apiName GetHomeLinks
@apiSuccessExample {json} Response-Example:
  {
     "home_links": [{
       "id": 1,
       "name": "ManUtd",
       "href": "http://www.manutd.com/Splash-Page.aspx"
     }]
   }
=end
  def index
    @home_links = HomeLink.all
    render 'api/v3/home_links/index'
  end
end
