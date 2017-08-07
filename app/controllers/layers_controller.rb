class LayersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_work
  before_action :find_layer, only: [:update, :destroy]

  def index
    @layers = @work.layers
    render 'layers/index'
  end

  def create
    if params[:file]
      create_photo_layer
    else
      create_other_layer
    end
  end

  def update
    if @layer.update_attributes(layer_params)
      render 'layers/show'
    else
      render json: { status: 'error', message: @layer.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    log_with_current_user @layer
    @layer.destroy
    render json: { status: 'ok' }
  end

  private

  def find_work
    @work = Work.find(params[:work_id])
  end

  def find_layer
    @layer = @work.layers.find_by!(uuid: params[:id])
  end

  def create_photo_layer
    @layer = @work.layers.new(
      layer_type:     'photo',
      image:          params[:file],
      filtered_image: params[:file],
      uuid:           params[:uuid],
      position:       params[:position],
      scale_x:        params[:scale_x],
      scale_y:        params[:scale_y]
    )
    log_with_current_user @layer
    @layer.save!
    render json: { url: @layer.filtered_image.url, uuid: @layer.uuid },
           status: :created
  end

  def create_other_layer
    @layer = @work.layers.new(layer_params)
    log_with_current_user @layer
    if @layer.save
      @layer.reload
      render 'layers/show', status: :created
    else
      render json: { status: 'error', message: @layer.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def layer_params
    params.permit(:uuid, :orientation, :scale_x, :scale_y, :color, :transparent,
                  :font_name, :font_text, :material_name, :layer_type,
                  :image, :filtered_image,
                  :position_x, :position_y, :text_spacing_x, :text_spacing_y,
                  :text_alignment, :position, :filter, :uuid, :position)
  end
end
