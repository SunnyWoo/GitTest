class Admin::FeesController < Admin::ResourcesController
  def new
    super
    @resource.build_currencies_set
  end

  def edit
    super
    @resource.build_currencies_set if @resource.currencies.count == 0
  end
end
