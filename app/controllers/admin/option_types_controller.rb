class Admin::OptionTypesController < AdminController
  before_action :find_option_type, only: [:show, :edit, :update, :destroy]

  def index
    @option_types = OptionType.all.page(params[:page])
  end

  def new
    @option_type = OptionType.new
  end

  def show
  end

  def create
    @option_type = OptionType.new(option_type_params)
    if @option_type.save
      redirect_to admin_option_types_path
    else
      flash.now[:error] = @option_type.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
    if @option_type.update(option_type_params)
      redirect_to admin_option_types_path
    else
      flash.now[:error] = @option_type.errors.full_messages
      render :edit
    end
  end

  def destroy
    @option_type.destroy
    redirect_to admin_option_types_path
  end

  private

  def find_option_type
    @option_type = OptionType.find(params[:id])
  end

  def option_type_params
    params.require(:option_type).permit(:name,
                                        :presentation,
                                        option_values_attributes: [:id, :name, :presentation, :_destroy])
  end
end
