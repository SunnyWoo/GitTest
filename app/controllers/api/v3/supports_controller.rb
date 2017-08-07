class Api::V3::SupportsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {get} /api/supports Get Supports category
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Supports
@apiName GetSupportsCategory
@apiSuccessExample {json} Response-Example:
 {
    "support": {
      "categories": [
        [
          "Product/產品",
          "product"
        ],
        [
          "Create Your Own/創建您自己的",
          "create_your_own"
        ],
        [
          "Billing/帳單",
          "billing"
        ],
        [
          "Shipping/運送",
          "shipping"
        ],
        [
          "Ordering/訂購",
          "ordering"
        ],
        [
          "Artist Information/藝術家",
          "artist_information"
        ]
      ]
    }
  }
=end
  def index
    @support = {
      categories: I18n.t('support.categories').map { |k, v| [v, k] }
    }
    render json: { support: @support }
  end

=begin
@api {post} /api/supports Create support
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Supports
@apiName CreateSupport
@apiParam {String} email email
@apiParam {String} category Support category
@apiParam {String} subject subject
@apiParam {String} description description
@apiParam {String} [name] name
@apiParam {File[]} [attachments] 附加檔案圖片
@apiSuccessExample {json} Response-Example:
 {
    status: 'success'
  }
=end
  def create
    zendesk_ticket = ZendeskForm.new(support_params)
    res = zendesk_ticket.save!
    if res[:status]
      res = { status: 'success' }
      status = :created
    else
      res = { error: res[:message], code: 'RecordInvalidError' }
      status = :unprocessable_entity
    end
    render json: res, status: status
  end

  private

  def support_params
    params.permit(:email,
                  :category,
                  :subject,
                  :description,
                  attachments: [],
                  attachment_ids: []).merge({ locale: locale, user: current_user })
  end
end
