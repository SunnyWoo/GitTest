class Api::V1::My::LayersController < ApiController
  before_action :authenticate_required!
  before_action :find_work

  # Layer info
  #
  # Url : /api/my/works/:work_uuid/layers/:layer_uuid
  #
  # RESTful : GET
  #
  # Get Example
  #   /api/my/works/6ec52444-5505-11e4-8170-3c15c2d24fd8/layers/6edc3102-5505-11e4-8170-3c15c2d24fd8
  #
  # Return Example
  #  {
  #    "uuid": "6edc3102-5505-11e4-8170-3c15c2d24fd8",
  #    "position_x": 276.27824311523,
  #    "position_y": 976.93158764792,
  #    "orientation": 282.27883709015,
  #    "scale_x": 1.8952176181557,
  #    "scale_y": 6.2160882519359,
  #    "color": "black",
  #    "font_name": "font_name",
  #    "font_text": "font_text",
  #    "image_url": "\/uploads\/layer\/image\/1\/test.jpg",
  #    "name": "layer name",
  #    "work_id": 1,
  #    "work_uuid": "6ec52444-5505-11e4-8170-3c15c2d24fd8",
  #    "layer_type": 1,
  #    "filter": "0",
  #    "text_spacing_x": 9,
  #    "text_spacing_y": 7,
  #    "position": 1,
  #    "text_alignment": "Left",
  #    "transparent": 2.0643082419673,
  #    "material_name": "layer name"
  #  }
  #
  # @param request work_uuid [String] Work uuid
  # @param request layer_uuid [String] Layer uuid
  #
  # @return [JSON] status 200

  def show
    @layer = @work.layers.where(uuid: params[:uuid]).first
    if @layer
      render 'api/v1/layers/show'
      fresh_when(etag: @layer, last_modified: @layer.updated_at)
    else
      render json: { status: 'error', message: 'Not found' }, status: 404
    end
  end

  # Create layer
  #
  # Url - /api/my/works/:work_uuid/layers
  #
  # RESTful - POST
  #
  # POST Example
  #  POST: /api/my/works/63b1403e-22c8-11e4-9db0-3c15c2d24fd8/layers
  #  {
  #    auth_token: "qwdqwd1233d12e1",
  #    uuid: "63ccaf22-22c8-11e4-9db0-3c15c2d24fd8",
  #    position_x: 787.09801274318,
  #    position_y: 65.029658401544,
  #    orientation: 60.504611124793,
  #    scale_x: 8.4051930393711,
  #    scale_y: 1.5843703951969,
  #    color: "black",
  #    font_name: "font_name",
  #    font_text: "font_text",
  #    image: "\/uploads\/layer\/image\/2\/test.jpg",
  #    name: "layer name",
  #    layer_type: 1,
  #    filtered_image: "\/uploads\/layer\/image\/2\/test.jpg",
  #    filter_type: 1,
  #    layer_no: 'no1',
  #    text_spacing_x: 7,
  #    text_spacing_y: 3,
  #    text_alignment: 9,
  #    transparent: 7.0398255873299
  #    material_name: "layer name"
  #  }
  #
  # Return Example
  #  {
  #    "uuid"=>"63ccaf22-22c8-11e4-9db0-3c15c2d24fd8",
  #    "position_x": 787.09801274318,
  #    "position_y": 65.029658401544,
  #    "orientation": 60.504611124793,
  #    "scale_x": 8.4051930393711,
  #    "scale_y": 1.5843703951969,
  #    "color": "black",
  #    "font_name": "font_name",
  #    "font_text": "font_text",
  #    "image_url": "\/uploads\/layer\/image\/2\/test.jpg",
  #    "name": "layer name",
  #    "work_id": 1,
  #    "work_uuid": "63b1403e-22c8-11e4-9db0-3c15c2d24fd8",
  #    "layer_type": 1,
  #    "filter": 0,
  #    "text_spacing_x": 7,
  #    "text_spacing_y": 3,
  #    "position": 1,
  #    "text_alignment": "Left",
  #    "transparent": 7.0398255873299,
  #    "material_name": "layer name"
  #  }
  #
  # @param request work_uuid - work uuid
  # @param request auth_token - user auth_token
  # @param request position
  # @param position_x - position x number
  # @param position_y - position y number
  # @param orientation - orientation 0 to 360
  # @param scale_x - scale x number
  # @param scale_y - scale y number
  # @param color - color
  # @param font_name - font name
  # @param font_text - font text
  # @param image - image path
  # @param name - layer name
  # @param layer_type - layer type is inclusive of :camera, :photo, :background_color,
  # @param              :shape, :crop, :line, :sticker, :texture, :typography, :text,
  # @param              :lens_flare, :spot_casting, :spot_casting_text
  # @param filtered_image - image path
  # @param filter_type - filter number
  # @param layer_no - layer No
  # @param text_spacing_x - text spacing x number
  # @param text_spacing_y - text spacing y number
  # @param text_alignment - text alignment number
  # @param transparent - transparent number
  # @param material_name - material name
  #
  # @return [JSON] status 201

  def create
    @layer = @work.layers.build(api_permitted_params.layer)
    if @layer.save
      log_with_current_user @layer
      render 'api/v1/layers/show', status: :created
    else
      render json: { status: 'error',
                     message: @layer.errors.full_messages }, status: :bad_request
    end
  end

  # Update layer
  #
  # Url - /api/my/works/:work_uuid/layers/:layer_uuid
  #
  # RESTful - PUT
  #
  # Put Example
  #  put: /api/my/works/fabf8bbe-550b-11e4-80eb-3c15c2d24fd8/layers/fad25910-550b-11e4-80eb-3c15c2d24fd8
  #  {
  #    name - 'Lyaer name update'
  #  }
  #
  # Return Example
  #  {
  #    "status": "success"
  #  }
  #
  # @param request work_uuid - work uuid
  # @param request layer_uuid - layer uuid
  # @param request auth_token - user auth_token
  # @param position_x - position x number
  # @param position_y - position y number
  # @param orientation - orientation 0 to 360
  # @param scale_x - scale x number
  # @param scale_y - scale y number
  # @param color - color
  # @param font_name - font name
  # @param font_text - font text
  # @param image - image path
  # @param name - layer name
  # @param layer_type - layer type is inclusive of :camera, :photo, :background_color,
  # @param              :shape, :crop, :line, :sticker, :texture, :typography, :text,
  # @param              :lens_flare, :spot_casting, :spot_casting_text
  # @param filtered_image - image path
  # @param filter_type - filter number
  # @param layer_no - layer No
  # @param text_spacing_x - text spacing x number
  # @param text_spacing_y - text spacing y number
  # @param text_alignment - text alignment number
  # @param transparent - transparent number
  # @param material_name - material name
  #
  # @return [JSON] status 200

  def update
    @layer = @work.layers.where(uuid: params[:uuid]).first
    if @layer.update(api_permitted_params.layer)
      render json: { status: 'success' }
    else
      render json: { status: 'error',
                     message: @layer.errors.full_messages }, status: 400
    end
  end

  # Delete layer
  #
  # Url - /api/my/works/:work_uuid/layers/:layer_uuid
  #
  # RESTful - DELETE
  #
  # DELETE Example
  #   /api/my/works/8fd4fe4c-550b-11e4-b02c-3c15c2d24fd8/layers/8fe8aba4-550b-11e4-b02c-3c15c2d24fd8
  #
  # Return Example
  #  {
  #    "status": "success"
  #  }
  #
  # @return [JSON] status 200

  def destroy
    @layer = @work.layers.where(uuid: params[:uuid]).first
    log_with_current_user @layer
    @layer.destroy
    render json: { status: 'success' }
  end

  protected

  def find_work
    @work = current_user.works.find_by!(uuid: params[:work_uuid])
    log_with_current_user @work
  end
end
