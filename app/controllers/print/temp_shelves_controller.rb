class Print::TempShelvesController < PrintController
  before_action :find_print_item
  before_action :find_temp_shelf, only: %i(edit update)

  def new
    authorize TempShelf, :create?
    @temp_shelf = @print_item.build_temp_shelf
  end

  def create
    authorize TempShelf, :create?
    temp_shelf = @print_item.create_temp_shelf!(temp_shelf_params)
    log_temp_shelf_activity(temp_shelf)
    redirect_to :back, notice: 'success'
  end

  def edit
    authorize TempShelf, :update?
    render :new
  end

  def update
    authorize TempShelf, :update?
    if @temp_shelf.update(temp_shelf_params)
      log_temp_shelf_activity(@temp_shelf)
      redirect_to :back, notice: '修改成功'
    else
      redirect_to :back, notice: @temp_shelf.errors.full_messages
    end
  end

  private

  def find_print_item
    @print_item = PrintItem.find(params[:print_item_id])
  end

  def find_temp_shelf
    @temp_shelf = TempShelf.find_by!(id: params[:id], print_item_id: @print_item.id)
  end

  def temp_shelf_params
    params.require(:temp_shelf).permit(:serial, :description)
  end

  def log_temp_shelf_activity(temp_shelf)
    current_factory.create_activity(:temp_shelf,
                                    print_item_id: @print_item.id,
                                    temp_shelf_id: temp_shelf.id,
                                    description: temp_shelf.description
                                   )
  end
end
