class Admin::HomeBlocksController < AdminController
  def index
    @home_blocks = HomeBlock.all

    respond_to do |f|
      f.html
      f.json { render 'api/v3/home_blocks/index' }
    end
  end

  def create
    @home_block = HomeBlock.create
    render_block(@home_block)
  end

  def update
    @home_block = HomeBlock.find(params[:id])
    if @home_block.update(update_params)
      render_block(@home_block)
    else
      render json: @home_block.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @home_block = HomeBlock.find(params[:id])
    @home_block.destroy
    render_block(@home_block)
  end

  private

  def update_params
    params.require(:block).permit(:template,
                                  :insert_position,
                                  title_translations: I18n.available_locales)
  end

  def render_block(block)
    @home_block = block
    respond_to do |f|
      f.json { render 'api/v3/home_blocks/show' }
    end
  end
end
