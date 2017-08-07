class Print::FactoriesController < PrintController
  def index
    @factory = current_factory
    @factory.build_ftp_gateway if @factory.ftp_gateway.nil?
  end

  def update
    if current_factory.update_attributes(print_permitted_params.factory)
      flash[:notice] = '修改成功！'
    else
      flash[:error] = current_factory.errors.full_messages
    end
    redirect_to action: :index
  end
end
