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
# = Work data format

=begin
@apiDefine V3_WrokWithoutLayersResponse
@apiSuccessExample {json} Response-Example:
    {
  "work": {
    "id": 3583,
    "gid": "Z2lkOi8vY29tbWFuZC1wL1dvcmsvMzU4Mw",
    "uuid": "78108a66-cc79-11e4-9ca2-ac87a30f9d14",
    "name": "Created By Api V3  yes",
    "user_avatar": {
      "avatar": {
        "url": "http://commandp.dev/uploads/user/avatar/1/1.jpg?v=1453971162",
        "s35": {
          "url": "http://commandp.dev/uploads/user/avatar/1/2.jpg?v=1453971162"
        },
        "s114": {
          "url": "http://commandp.dev/uploads/user/avatar/1/3.jpg?v=1453971162"
        },
        "s154": {
          "url": "http://commandp.dev/uploads/user/avatar/1/4.jpg?v=1453971162"
        }
      }
    },
    "user_id": 1,
    "order_image": {
      "thumb": null,
      "share": null,
      "sample": null,
      "normal": null
    },
    "gallery_images": [],
    "original_prices": {
      "TWD": 899,
      "USD": 29.95,
      "JPY": 3480,
      "HKD": 229
    },
    "prices": {
      "TWD": 899,
      "USD": 29.95,
      "JPY": 3480,
      "HKD": 229
    },
    "user_display_name": "",
    "wishlist_included": false,
    "slug": "my-design-a2bbae40-5a50-479c-bd87-296503c15fe1",
    "is_public": false,
    "user_avatars": {
      "s35": "http://commandp.dev/uploads/user/avatar/1/s35_.jpg?v=1453971162",
      "s154": "http://commandp.dev/uploads/user/avatar/1/s154_.jpg?v=1453971162"
    },
    "spec": {
      "id": 8,
      "name": "iPhone 6 Plus 手機殼",
      "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n-熱轉印特殊防刮抗磨塑料",
      "width": 99,
      "height": 178,
      "dpi": 300,
      "background_image": null,
      "overlay_image": null,
      "padding_top": "0.0",
      "padding_right": "0.0",
      "padding_bottom": "0.0",
      "padding_left": "0.0",
      "__deprecated": "WorkSpec is not longer available"
    },
    "model": {
      "id": 8,
      "key": "iphone_6plus_cases",
      "name": "iPhone 6 Plus 手機殼",
      "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n-熱轉印特殊防刮抗磨塑料",
      "prices": {
        "TWD": 899,
        "USD": 29.95,
        "JPY": 3480,
        "HKD": 229
      },
      "customized_special_prices": null,
      "design_platform": {
        "ios": true,
        "android": true,
        "website": true
      },
      "customize_platform": {
        "ios": false,
        "android": false,
        "website": true
      },
      "placeholder_image": null,
      "width": 99,
      "height": 178,
      "dpi": 300,
      "background_image": null,
      "overlay_image": null,
      "padding_top": "0.0",
      "padding_right": "0.0",
      "padding_bottom": "0.0",
      "padding_left": "0.0"
    },
    "product": {
      "id": 8,
      "key": "iphone_6plus_cases",
      "name": "iPhone 6 Plus 手機殼",
      "description": "- 一體成型高溫塑膜\r\n- PVC硬殼保護你的手機\r\n-熱轉印特殊防刮抗磨塑料",
      "prices": {
        "TWD": 899,
        "USD": 29.95,
        "JPY": 3480,
        "HKD": 229
      },
      "customized_special_prices": null,
      "design_platform": {
        "ios": true,
        "android": true,
        "website": true
      },
      "customize_platform": {
        "ios": false,
        "android": false,
        "website": true
      },
      "placeholder_image": null,
      "width": 99,
      "height": 178,
      "dpi": 300,
      "background_image": null,
      "overlay_image": null,
      "padding_top": "0.0",
      "padding_right": "0.0",
      "padding_bottom": "0.0",
      "padding_left": "0.0"
    },
    "category": {
      "id": 5,
      "key": "case",
      "name": "手機殼"
    },
    "featured": false,
    "tags": [
      {
        "id": 3,
        "name": "tag_1",
        "text": "标签1"
      },
      {
        "id": 6,
        "name": "tag_2",
        "text": "标签2"
      }
    ]
  }
}
=end

class Api::V3::My::WorksController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user
  before_action :find_work, only: [:show, :finish, :destroy]
  before_action :find_or_initialize_work, only: :update

=begin
@api {get} /api/my/works/ Get the user's works
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup MyWorks
@apiName ListMyWork
@apiSuccessExample {json} Response-Example:
{
  "works": [
    {
      "id": 3617,
      "uuid": "c5847ab2-448f-11e5-8688-ac87a30f9d14",
      "name": "My Design",
      "user_avatar": {
        "avatar": {
          "url": "http://commandp.dev/uploads/user/avatar/1/03bf5b.jpg?v=1446519621",
          "s35": {
            "url": "http://commandp.dev/uploads/user/avatar/1/s35_b.jpg?v=1446519621"
          },
          "s114": {
            "url": "http://commandp.dev/uploads/user/avatar/1/s114_0b.jpg?v=1446519621"
          },
          "s154": {
            "url": "http://commandp.dev/uploads/user/avatar/1/s154_05b.jpg?v=1446519621"
          }
        }
      },
      "user_id": 1,
      "order_image": {
        "thumb": null,
        "share": null,
        "sample": null,
        "normal": null
      },
      "gallery_images": [],
      "prices": {
        "TWD": 899,
        "USD": 29.95,
        "JPY": 3480,
        "HKD": 229
      },
      "original_prices": {
        "TWD": 899,
        "USD": 29.95,
        "JPY": 3480,
        "HKD": 229
      },
      "user_display_name": "陳勇嘉",
      "wishlist_included": false,
      "slug": "my-design-2e666d52-9a80-4a2d-8007-e2b74aa23c7e",
      "is_public": false,
      "user_avatars": {
        "s35": "http://commandp.dev/uploads/user/avatar/190f29f5b.jpg?v=1446519621",
        "s154": "http://commandp.dev/uploads/user/avatar/1/s154f29f5b.jpg?v=1446519621"
      },
      "spec": {
        "id": 19,
        "name": "iPad Air 2 保護套",
        "description": "設計你獨一無二",
        "width": 1352,
        "height": 1247,
        "dpi": 1300,
        "background_image": null,
        "overlay_image": null,
        "padding_top": "0.0",
        "padding_right": "0.0",
        "padding_bottom": "0.0",
        "padding_left": "0.0",
        "__deprecated": "WorkSpec is not longer available"
      },
      "model": {
        "id": 19,
        "key": "ipad_air2_covers",
        "name": "iPad Air 2 保護套"
      },
      "category": {
        "id": 4,
        "key": "cover",
        "name": "保護套"
      },
      "tags": [
        {
          "id": 3,
          "name": tag_1,
          "text": "标签1"
        },
        {
          "id": 6,
          "name": "tag_2",
          "text": "标签2"
        }
      ]
    }  ],
  "meta": {
    "works_count": 106
  }
}
=end

  def index
    @works = current_user.works.finished.order('created_at DESC')
    fresh_when(etag: @works)
  end

=begin
@api {get} /api/my/works/:uuid Get the user work
@apiUse ApiV3
@apiUse V3_WrokWithoutLayersResponse
@apiVersion 3.0.0
@apiGroup MyWorks
@apiName ShowMyWork
@apiParam {String} uuid work's uuid
=end

  def show
    render 'api/v3/works/show'
    fresh_when(etag: @work, last_modified: @work.updated_at)
  end

=begin
@api {put} /api/my/works/:uuid Create or update the work
@apiUse ApiV3
@apiUse V3_WrokWithoutLayersResponse
@apiVersion 3.0.0
@apiGroup MyWorks
@apiName UpdateMyWork
@apiParam {String} [uuid] work's uuid
@apiParam {String} [name] work name
@apiParam {Integer} [model_id] model's id
@apiParam {Integer} [spec_id] spec's id
@apiParam {File} [cover_image] cover image
@apiParam {String} [cover_image_aid] cover_image's aid
=end

  def update
    @work.update!(work_params)
    @work.reload
    if feature(:api_v3_my_work_enable_attachment_aid).enable_for_current_session?
      @work.enqueue_build_previews_by_cover_image
    end
    render 'api/v3/works/show'
  end

=begin
@api {post} /api/my/works/:uuid/finish Finish the work
@apiUse ApiV3
@apiUse V3_WrokWithoutLayersResponse
@apiVersion 3.0.0
@apiGroup MyWorks
@apiName FinishMyWork
@apiParam {String} uuid work's uuid
@apiParam {Boolean="true","false"} [simple] Response simple-mode
=end

  def finish
    @work.finish!
    if params[:simple].to_b
      render plain: nil
    else
      render 'api/v3/works/show'
    end
  end

=begin
@api {delete} /api/my/works/:uuid Delete user's work
@apiUse ApiV3
@apiUse V3_WrokWithoutLayersResponse
@apiVersion 3.0.0
@apiGroup MyWorks
@apiName DeleteMyWork
@apiParam {String} uuid work's uuid
=end

  def destroy
    @work.destroy
    render 'api/v3/works/show'
  end

  private

  def find_work
    @work = Work.non_store.find_by!(uuid: params[:uuid])
    log_with_current_user @work
    return if @work.user == current_user
    if @work.user != current_user && @work.user.guest? && !current_user.guest?
      @work.update(user: current_user)
    else
      fail RecordNotFoundError
    end
  end

  def find_or_initialize_work
    find_work
  rescue ActiveRecord::RecordNotFound, RecordNotFoundError
    @work = current_user.works.new(uuid: params[:uuid],
                                   user: current_user,
                                   application: current_application)
    log_with_current_user @work
  end

  def work_params
    # TODO: 當手機 app 都完成遷移時移除 spec_id
    tmp = params.permit(:name, :model_id, :spec_id, :cover_image, :cover_image_aid,
                        :perform_destroy_previews)
    if feature(:api_v3_my_work_enable_attachment_aid).enable_for_current_session?
      cover_image_aid = tmp.delete(:cover_image_aid)
      tmp[:attached_cover_image_id] = Attachment.find_by_aid!(cover_image_aid).id if cover_image_aid.present?
    end
    tmp
  end
end
