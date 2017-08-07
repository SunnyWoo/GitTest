class Api::V3::StoresController < ApiV3Controller
  before_action :find_store, only: %w(show)

=begin
@api {get} /api/stores/:id Get the specific store info
@apiDescription 回傳公開的店家資訊
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Stores
@apiName getStoreInfo
@apiParam {String} id 店家 id，或是 slug
@apiSuccessExample {json} Response-Example:
 {
    "store": {
      "id": 1,
      "slug": "example-store",
      "avatar": "http://commandp.dev/assets/img_fbdefault.png?v=1472441297",
      "title": "康面Ｐ的店",
      "description": "Example Store for Example"
    }
  }
=end
  def show
  end

  private

  def find_store
    @store = Store.find(params[:id])
  end
end
