class Api::V3::ContactsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {post} /api/contacts Create Contents
@apiDescription B2B 聯繫相關資訊 使用，node 網站回傳相關資訊後，轉寄信件給相關人員。
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Contents
@apiName CreateContents
@apiParam {String} contents 聯繫相關資訊, 內容太長可以使用 <br /> or \n 換行
@apiSuccessExample {json} Response-Example:
 {
    status: 'success'
  }
@apiErrorExample {json} Response-Example:
 {
    status: 'success'
  }
=end
  def create
    emails = SiteSetting.by_key('B2BContacsReceiver') || 'rich.ke@commandp.com'
    title = "B2B 與 #{I18n.t('site.name')}聯繫"
    res = if NoticeAdminSender.perform_async(emails, title, params[:contents])
            { status: 'success' }
          else
            { status: 'error' }
          end
    render json: res
  end
end
