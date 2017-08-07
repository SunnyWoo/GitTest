class Admin::MasksController < Admin::ResourcesController
  def index
    @search = model_class.ransack(params[:q])
    @resources = @search.result.page(params[:page] || 1)
  end

  def new
    super
  end

  def create
    super
  end

  def destroy
    super
  end
end
