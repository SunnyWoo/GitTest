class Api::V3::MobileUisController < ApiV2Controller
=begin
@api {get} /api/mobile_uis/template?key={key} Get Mobile UI template
@apiGroup MobileUI
@apiName GetMobileUITemplate
@apiVersion 3.0.0
@apiParam {String} key The template key
@apiSuccessExample {json} Success-Response:
  {
    "mobile_ui": {
      "title": "Test King",
      "template": "shop",
      "device_type": "iOS",
      "links": {
        "h_3":    "http://commandp.dev/uploads/mobile_ui/image/1/h_3_151ad4011ce161.jpg?v=1426828759",
        "m_1":    "http://commandp.dev/uploads/mobile_ui/image/1/m_1_151ad4011ce161.jpg?v=1426828759",
        "origin": "http://commandp.dev/uploads/mobile_ui/image/1/151ad4011ce161.jpg?v=1426828759"
      }
    }
  }
@apiError (Error 400) ParametersInvalidError The template is not found
=end
  def template
    @mobile_ui = MobileUi.available.where(template: template_key).hotest_enabled.first || MobileUi.default.first
    render 'api/v3/mobile_uis/show'
  end

  private

  def template_key
    if MobileUi.all.pluck(:template).include? params[:key]
      params[:key]
    else
      fail ParametersInvalidError, caused_by: params[:key]
    end
  end
end
