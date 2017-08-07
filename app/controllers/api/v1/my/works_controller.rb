class Api::V1::My::WorksController < ApiController
  before_action :authenticate_required!
  before_action :find_work, only: %w'show finish update destroy'
  before_action :find_or_initialize_work, only: 'create'

  # Work list
  #
  # Url : /api/my/works
  #
  # RESTful : GET
  #
  # Get Example
  #   /api/my/works
  #
  # Return Example
  #   [
  #     {
  #       "uuid": "8d6b5cdc-59d4-11e4-9fc8-3c15c2d24fd8",
  #       "finished": false,
  #       "cover_image": {
  #         "thumb": "\/uploads\/work\/cover_image\/1\/thumb_test.jpg",
  #         "normal": "\/uploads\/work\/cover_image\/1\/test.jpg"
  #       },
  #       "name": "work name",
  #       "model": "iphone8",
  #       "editable": false,
  #       "feature": false,
  #       "user": {
  #         "id": 1,
  #         "email": "user1@commandp.me",
  #         "avatar": {
  #           "thumb": "\/assets\/editor\/default_avatar.png",
  #           "normal": "\/assets\/editor\/default_avatar.png"
  #         },
  #         "username": null,
  #         "role": "normal"
  #       }
  #     }
  #   ]
  #
  # @return [JSON] status 200
  def index
    @works = current_user.works
    render json: @works, root: false
    fresh_when(etag: @works)
  end

  # Show user work
  #
  # Url : /api/my/works/:uuid
  #
  # RESTful : GET
  #
  # Get Example
  #   /api/my/works/e6fd848c-59d4-11e4-8810-3c15c2d24fd8
  #
  # Return Example
  #   {
  #     "uuid":"e6fd848c-59d4-11e4-8810-3c15c2d24fd8",
  #     "finished": false,
  #     "cover_image": {
  #       "thumb": "\/uploads\/work\/cover_image\/1\/thumb_test.jpg",
  #       "normal": "\/uploads\/work\/cover_image\/1\/test.jpg"
  #     },
  #     "name": "work name",
  #     "model": "iphone7",
  #     "user": {
  #       "id": 1,
  #       "email": "user1@commandp.me",
  #       "avatar": {
  #         "thumb": null,
  #         "normal": null
  #       },
  #       "username": null,
  #       "role": "normal"
  #     }
  #   }
  #
  # @param request uuid [Strign] Work uuid
  #
  # @return [JSON] status 200
  def show
    render json: @work, root: false
    fresh_when(etag: @work, last_modified: @work.updated_at)
  end

  # User create work
  #
  # Url : /api/my/works
  #
  # RESTful : POST
  #
  # Post Example
  #   post /api/my/works
  #   {
  #     uuid: "f3dc1c80-59d5-11e4-a374-3c15c2d24fd8",
  #     name: "work",
  #     cover_image: ,
  #     auth_token: "user auth_token",
  #     model: "iphone8"
  #   }
  #
  # Return Example
  #   {
  #     "uuid": "f3dc1c80-59d5-11e4-a374-3c15c2d24fd8",
  #     "finished": false,
  #     "cover_image": {
  #       "thumb": null,
  #       "normal": "\/uploads\/work\/cover_image\/1\/test.jpg"
  #     },
  #     "name": "work",
  #     "model": "iphone8",
  #     "editable": false,
  #     "feature": false,
  #     "user": {
  #       "id": 1,
  #       "email": "user1@commandp.me",
  #       "avatar": {
  #         "thumb": "\/assets\/editor\/default_avatar.png",
  #         "normal": "\/assets\/editor\/default_avatar.png"
  #       },
  #       "username": null,
  #       "role": "normal"
  #     }
  #   }
  #
  # @param request auth_token [String] user token
  # @param request name [String] work name
  # @param uuid [String] Universally Unique Identifier
  # @param description [String] work description
  # @param cover_image [String] work image file
  # @param model [String] product model name
  # @param spec [String] work spec name, will use the first spec of model if client didn't give this value
  #
  # Returns JSON, status 201
  def create
    @work.layers.destroy_all
    @work.attributes = api_permitted_params.work
    @work.work_type ||= 'is_private'
    log_with_current_user @work
    if @work.save
      @work.reload
      render json: @work, root: false, status: (@persisted ? :ok : :created)
    else
      render json: { status: 'error',
                     message: @work.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Update work to finish
  #
  # Url : /api/my/works/:work_uuid/finish
  #
  # RESTful - PATCH
  #
  # Patch Example
  #   patch /api/my/works/baa793ca-5a09-11e4-8f69-3c15c2d24fd8/finish
  #
  # Return Example
  #   {
  #     "uuid":"baa793ca-5a09-11e4-8f69-3c15c2d24fd8",
  #     "name": "work name",
  #     "description": "description do  ... ",
  #     "model": {
  #       "key": 'iphone_6_cases',
  #       "name": 'iPhone 6',
  #     },
  #     "cover_image": {
  #       "thumb": "\/uploads\/work\/cover_image\/1\/thumb_test.jpg",
  #       "normal": "\/uploads\/work\/cover_image\/1\/test.jpg"
  #     },
  #     "policy": "private",
  #     "finished": true,
  #     "layers": [],
  #     "user": {
  #       "id": 1,
  #       "email": "user1@commandp.me",
  #       "avatar": {
  #         "thumb": null,
  #         "normal": null
  #       },
  #       "username": null,
  #       "role": "normal"
  #     }
  #   }
  #
  # @param work_uuid [String] Work uuid
  # auth_token - user token
  #
  # @return [JSON] status 200
  def finish
    log_with_current_user @work
    if @work.finish!
      @work.enqueue_build_print_image
      render json: @work, serializer: FinishWorkSerializer, root: false
    else
      render json: { status: 'error',
                     message: @work.errors.full_messages }, status: 400
    end
  end

  # Update work
  #
  # Url : /api/my/works/:uuid
  #
  # RESTful : PUT
  #
  # Put Example
  #   puts /api/my/works/a97d6178-5a0a-11e4-9030-3c15c2d24fd8
  #   {
  #     name: 'update_work',
  #     auth_token: user auth_token
  #   }
  #
  # Return Example
  #   {
  #     "status":"success"
  #   }
  #
  # @param [type] [description]
  # @param uuid [String] work uuid
  # @param name [String] work name
  # @param description [String] work description
  # @param cover_image [File] work image file
  # @param model [String] product_model name
  # @param spec [String] work spec name, will use the first spec of model if client didn't give this value
  # @param auth_token [String] user token
  #
  # @return [JSON] status 200
  def update
    # To Do
    # 手機端目前沒有寫針對 layer 的操作，所以在使用者更新圖層的時候無法用更新的方式進行
    # 所以目前當手機端發送 patch 的時候先把原有的圖層都刪除，以免圖層無限增加
    log_with_current_user @work
    @work.layers.each do |layer|
      log_with_current_user layer
      layer.destroy
    end
    if @work.update(api_permitted_params.work)
      @work.enqueue_build_print_image
      render json: { status: 'success' }, status: :ok
    else
      render json: { status: 'error',
                     message: @work.errors.full_messages }, status: 400
    end
  end

  # Destroy work
  #
  # Url : /api/my/works/:uuid
  #
  # RESTful : DELETE
  #
  # Destory Example
  #    DELETE /api/my/works/:uuid
  #
  # Return Example
  #   {
  #     "status":"success"
  #   }
  #
  # @param uuid [String] work uuid
  # @param auth_token [String] user token
  #
  # @return [JSON] status 200
  def destroy
    if @work.destroy
      render json: { status: 'success' }
    end
  end

  private

  def find_work
    @work = current_user.works.find_by!(uuid: params[:uuid])
  rescue ActiveRecord::RecordNotFound
    @work = Work.find_by!(uuid: params[:uuid])
    if @work.user.guest? && !current_user.guest?
      @work.update(user: current_user)
    else
      raise
    end
  end

  def find_or_initialize_work
    find_work
    @persisted = true
  rescue ActiveRecord::RecordNotFound
    @work = current_user.works.where(uuid: params[:uuid]).new(user: current_user)
    @persisted = false
  end

  rescue_from ActiveRecord::RecordNotFound do |ex|
    render json: { status: 'error', message: 'Not found' }, status: 404
  end
end
