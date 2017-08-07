class Api::V2::BdeventsController < ApiV2Controller
=begin
@api {get} /api/bdevents Get bd events
@apiVersion 2.0.0
@apiGroup Bdevents
@apiName GetBdevents
@apiSuccessExample {json} Success-Response:
{
  "status": true,
  "url": "http://test.host/mobile_bdevent"
}
=end
  def index
    bdevents = Bdevent.event_available
    res = if bdevents.size > 0
            # TODO url 需要在改成 event mobile url
            { status: true, url: root_url('mobile_bdevent') }
          else
            { status: false, message: '抱歉！目前沒有活動敬請期待' }
          end
    render json: res
  end
end
