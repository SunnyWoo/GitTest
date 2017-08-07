class Admin::DevicesController < AdminController
  def index
    @search = Device.ransack(params[:q])
    @devices = @search.result.page(params[:page])
  end

  def count
    if params[:q] && params[:q][:country_code_in]
      params[:q][:country_code_in] = params[:q][:country_code_in].split(',')
    end
    device_count = Device.ransack(params[:q]).result.available.count
    render json: {
      device_count: device_count
    }
  end
end
