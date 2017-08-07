class Admin::RewardsController < Admin::ResourcesController
  def index
    @search = model_class.search(params[:q])
    @resources = @search.result(distinct: true).order("created_at desc").page(params[:page] || 1).per_page(30)
  end
end
