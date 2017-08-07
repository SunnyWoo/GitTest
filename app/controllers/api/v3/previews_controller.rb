class Api::V3::PreviewsController < ApiV3Controller
  before_action :doorkeeper_authorize!
  before_action :check_user
  before_action :find_resource

=begin
@api {get} /api/works/:work_id/previews Get work previews info
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Previews
@apiName GetPreviews
@apiSuccessExample {json} Response-Example:
  {
    "work": {
      "ready": false,
      "previews": [{
        "key": "order-image",
        "url": "/api/previews/key"
      }, {
        "key": "not-ready",
        "url": null
      }]
    }
  }
=end
  def index
    if @work.is_a?(Work)
      @previews = @work.product.preview_composers.available.where.not(key: Preview::STORE_PREVIEW_KEYS).each_with_object([]) do |composer, array|
        array << @work.previews.find_or_initialize_by(key: composer.key)
      end
    else
      @previews = @work.previews
    end
    render 'api/v3/previews/index'
  end

  private

  def find_resource
    case
    when params[:work_id] then find_work
    when params[:standardized_work_id] then find_standardized_work
    end
  end

  def find_work
    @work = find_owned_work(params[:work_id]) ||
            find_public_work(params[:work_id]) ||
            fail(RecordNotFoundError, "Couldn't find Work with 'id'=#{params[:work_id]}")
    log_with_current_user @work
  end

  def find_owned_work(id)
    current_user.works.non_store.find_by(slug: id) || current_user.works.non_store.find_by(uuid: id)
  end

  def find_public_work(id)
    Work.non_store.is_public.find_by(slug: id) || Work.non_store.is_public.find_by(uuid: id)
  end

  def find_standardized_work
    @work = StandardizedWork.non_store.published.find_by(slug: params[:standardized_work_id]) ||
            StandardizedWork.non_store.published.find_by!(uuid: params[:standardized_work_id])
  end
end
