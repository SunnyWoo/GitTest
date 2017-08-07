class Admin::FactoriesController < AdminController
  def index
    @factories = Factory.order('id').page(params[:page])
  end

  def new
    @factory = Factory.new
  end

  def create
    @factory = Factory.new(factory_params)
    if @factory.save
      redirect_to admin_factories_path
    else
      render :new
    end
  end

  def edit
    @factory = Factory.find(params[:id])
  end

  def update
    @factory = Factory.find(params[:id])
    if @factory.update(factory_params)
      redirect_to admin_factories_path
    else
      render :edit
    end
  end

  def destroy
    redirect_to :back, notice: 'Not implement yet'
  end

  private

  def factory_params
    params.require(:factory).permit(:code, :name, :contact_email, :locale)
  end
end
