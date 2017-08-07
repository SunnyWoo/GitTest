class Api::V3::CampaignsController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :find_campaigns, except: %w(waterpackage)
  before_action :find_campaign, only: [:show]

=begin
@api {get} /api/campaigns Get all user available campaigns
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Campaigns
@apiName ListAllCampaigns
@apiParam {String} preview get preparing campaigns
@apiSuccessExample {json} Response-Example:
  {
    "campaigns": [
      {
        "id": 1,
        "name": "aaaaa",
        "key": "aaaaa",
        "title": "AAA Campaign",
        "desc": "this is test Campaign",
        "designer_username": "aaaaa",
        "artworks_class": "grid_3 camp_artworks",
        "wordings": {
          "campaign_head": "aaaaa"
        },
        "about_designer": "aaaaa has five 'a'.  Not one,  BUT FIVE!!!!",
        "campaign_images": [
          {
            "id": 2,
            "key": "kv_tc",
            "desc": "",
            "url": "http://commandp.dev/uploads/campaign_image/file/2/S__12992527.jpg?v=1444617235"
          },
          {
            "id": 1,
            "key": "kv_bg",
            "desc": "",
            "url": "http://commandp.dev/uploads/campaign_image/file/1/19889_1273517_358954.jpg?v=1444617235"
          }
        ]
      }
    ]
  }
=end
  def index
  end

=begin
@api {get} /api/campaigns/:id Get a user available campaigns
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Campaigns
@apiName ShowCampaign
@apiParam {String} id campaing's id or key
@apiParam {String} preview see preparing campaign
@apiSuccessExample {json} Response-Example:
{
  "campaign": {
    "id": 1,
    "name": "aaaaa",
    "key": "aaaaa",
    "title": "AAA Campaign",
    "desc": "this is test Campaign",
    "designer_username": "aaaaa",
    "artworks_class": "grid_3 camp_artworks",
    "wordings": {
      "campaign_head": "aaaaa"
    },
    "about_designer": "aaaaa has five 'a'.  Not one,  BUT FIVE!!!!",
    "campaign_images": [
      {
        "id": 2,
        "key": "kv_tc",
        "desc": "",
        "url": "http://commandp.dev/uploads/campaign_image/file/2/S__12992527.jpg?v=1444617235"
      },
      {
        "id": 1,
        "key": "kv_bg",
        "desc": "",
        "url": "http://commandp.dev/uploads/campaign_image/file/1/19889_1273517_358954.jpg?v=1444617235"
      }
    ]
  }
}
=end
  def show
  end

=begin
@api {post} /api/campaigns/waterpackage Create campaign water package order
@apiDescription Only for china 水包裝活動
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Campaigns
@apiName CreateCampaignWaterpackage
@apiParam {String} uuid Order uuid
@apiParam {String} payment payment method
@apiParam {Object} billing_info billing's info structure
@apiParam {String="waterpackage_350ml", "waterpackage_350ml_6pcs"} product_key 可能會再調整
@apiParam {String[]} payload ex: [{ name: '丁一', school_name: '北大' }]
@apiUse OrderResponse
=end
  def waterpackage
    order = current_user.orders.where(uuid: params[:uuid]).first_or_initialize
    form = Campaign::WaterpackageOrder.new(order, waterpackage_order_params)
    fail OrderError, form.errors.full_messages.join(',') unless form.save
    @order = Api::V3::OrderDecorator.new(order)
    render 'api/v3/my/orders/show'
  end

  private

  def find_campaign
    @campaign = @campaigns.find_by(id: params[:id]) || @campaigns.find_by!(key: params[:id])
  end

  def find_campaigns
    @campaigns = if params[:preview]
                   Campaign.is_preparing
                 else
                   Campaign.is_published
                 end
  end

  def waterpackage_order_params
    api_permitted_params.order.merge(platform: os_type,
                                     ip: remote_ip,
                                     user_agent: user_agent,
                                     locale: locale,
                                     app_id: current_application.id,
                                     currency: 'CNY', # only CN
                                     payload: params[:payload],
                                     product_key: params[:product_key])
  end
end
