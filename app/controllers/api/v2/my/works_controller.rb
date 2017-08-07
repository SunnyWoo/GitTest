# = Work API and the uploading flow
#
# 0. `PUT /my/works/:uuid` without images.
#
# 1. After 0 ok, `PUT /my/works/:uuid` with images.
#
# 2. After 1 ok, `PUT /my/works/:work_uuid/layers/:uuid`.
#
# 3. After all 2 ok, `GET /my/works/:uuid`.
#
# 4. Checking 3's return value, if anything goes wrong, send some patch requests, else go 6.
#
#    * For every missing and wrong layer, `PUT /my/works/:work_uuid/layers/:uuid`.
#
#    * For every unused layers, `DELETE  /my/works/:work_uuid/layers/:uuid`.
#
# 5. After all 4 ok, go 3.
#
# 6. `POST /my/works/:uuid/finish`.
#
# 7. After 6 ok, YEAH! You have done the uploading flow!
#
=begin
@apiDefine WorkResponseWithLayer
@apiSuccessExample {json} Response(Work with layers data):
  {
    "work": {
      "uuid": "a546f9c6-76c9-11e4-9941-0c4de9c8b9e5",
      "name": "My Design",
      "finished": false,
      "cover_image": {
        "thumb": "http://commandp.dev/uploads/work/cover_image/271/82_cover_image.jpg?v=1417157396",
        "normal": "http://commandp.dev/uploads/work/cover_image/271/47_cover_image.jpg?v=1417157396",
        "shop": "http://commandp.dev/uploads/work/order_image/271/order_image20141128.jpg?v=1417157396"
      },
      "prices": {
        "TWD": 999,
        "USD": 32.99
      },
      "original_prices": {
        "TWD": 999,
        "USD": 32.99
      },
      "spec": {
        "id": 1,
        "name": "cover",
        "description": "潮殼",
        "width": 75.0,
        "height": 135.0,
        "dpi": 300
      },
      "model": {
        "id": 1,
        "key": "iphone-5s-5",
        "name": "iPhone 5s/5"
      },
      "layers": [
        {
          "uuid": "a55845aa-76c9-11e4-9941-0c4de9c8b9e5",
          "layer_type": "photo",
          "position_x": 40.300247,
          "position_y": 0.0,
          "orientation": 0.0,
          "scale_x": 0.245300725102425,
          "scale_y": 0.245300725102425,
          "transparent": 1.0,
          "color": "0x000000",
          "material_name": "19B8A0FE-B18E-4CA6-80BA-C7B35D11EAD7",
          "font_name": null,
          "font_text": null,
          "text_alignment": "Left",
          "text_spacing_x": null,
          "text_spacing_y": null,
          "image": {
            "normal": null,
            "thumb": null
          },
          "filtered_image": {
            "normal": "http://commandp.dev/uploads/layer/filtered_image/C7B35D11EAD7_f.jpg?v=1417156916",
            "thumb": "http://commandp.dev/uploads/layer/filtered_image/C7B35D11EAD7_t.jpg?v=1417156916"
          },
          "position": 1
        }
      ]
    }
  }
=end
=begin
@apiDefine WorkResponse
@apiSuccessExample {json} Response(Work without layers data):
  {
    "work": {
      "uuid": "a546f9c6-76c9-11e4-9941-0c4de9c8b9e5",
      "name": "My Design",
      "finished": false,
      "cover_image": {
        "thumb": "http://commandp.dev/uploads/work/cover_image/271.jpg?v=1417157396",
        "normal": "http://commandp.dev/uploads/work/cover_image/271.jpg?v=1417157396",
        "shop": "http://commandp.dev/uploads/work/order_image/271-12815-lpyx09.jpg?v=1417157396"
      },
      "prices": {
        "TWD": 999,
        "USD": 32.99
      },
      "spec": {
        "id": 1,
        "name": "cover",
        "description": "潮殼",
        "width": 75.0,
        "height": 135.0,
        "dpi": 300
      },
      "model": {
        "id": 1,
        "key": "iphone-5s-5",
        "name": "iPhone 5s/5"
      }
    }
  }
=end
class Api::V2::My::WorksController < ApiV2Controller
  before_action :authenticate_required!
  before_action :find_work, only: %w(show finish)
  before_action :find_or_initialize_work, only: 'update'

=begin
@api {get} /api/my/works/:uuid Get the work data by given uuid
@apiUse NeedAuth
@apiUse WorkResponseWithLayer
@apiGroup My/Works
@apiName GetMyWork
@apiVersion 2.0.0
=end
  def show
    fresh_when(etag: @work, last_modified: @work.updated_at)
  end

=begin
@api {put} /api/my/works/:uuid Create or update the work
@apiUse NeedAuth
@apiUse WorkResponse
@apiGroup My/Works
@apiName PutMyWork
@apiVersion 2.0.0
@apiParamExample {json} Request-Example
  PUT http://commandp.dev/api/my/works/a97d6178-5a0a-11e4-9030-3c15c2d24fd8
  {
     auth_token: '2337832c5e9a770c41d4db73875c9423'
     name: 'My Great Design',
     model_id: 9,
     cover_image: <file>,
     order_image: <file>
  }
=end
  def update
    @work.update!(work_params)
    @work.reload
    render 'api/v3/works/show'
  end

=begin
@api {post} /api/my/works/:uuid/finisha Finish the work
@apiUse NeedAuth
@apiUse WorkResponse
@apiGroup My/Works
@apiName FinishMyWork
@apiVersion 2.0.0
=end
  def finish
    @work.finish!
    render 'api/v3/works/show'
  end

  private

  def find_work
    @work = Work.find_by!(uuid: params[:uuid])
    log_with_current_user @work
    return if @work.user == current_user
    if @work.user != current_user && @work.user.guest? && !current_user.guest?
      @work.update(user: current_user)
    else
      raise RecordNotFoundError
    end
  end

  def find_or_initialize_work
    find_work
  rescue ActiveRecord::RecordNotFound, RecordNotFoundError
    @work = current_user.works.new(uuid: params[:uuid], user: current_user)
    log_with_current_user @work
  end

  # TODO: 當手機 app 都完成遷移時移除 spec_id
  def work_params
    params.permit(:name, :model_id, :spec_id, :cover_image)
  end
end
