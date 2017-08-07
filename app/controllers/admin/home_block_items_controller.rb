class Admin::HomeBlockItemsController < AdminController
  def index
    @block_items = HomeBlockItem.all
    render 'api/v3/home_block_items/index'
  end

  def create
    @block_item = HomeBlockItem.create(create_params)
    render_block_item(@block_item)
  end

  def update
    @block_item = HomeBlockItem.find(params[:id])
    if @block_item.update(update_params)
      render_block_item(@block_item)
    else
      render json: @block_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @block_item = HomeBlockItem.find(params[:id])
    @block_item.destroy
    render_block_item(@block_item)
  end

  private

  def create_params
    params.require(:block_item).permit(:block_id)
  end

  def update_params
    params.require(:block_item).permit(:insert_position, :image, :href,
                                       title_translations: I18n.available_locales,
                                       subtitle_translations: I18n.available_locales)
  end

  def render_block_item(block_item)
    @block_item = block_item
    render 'api/v3/home_block_items/show'
  end
end
