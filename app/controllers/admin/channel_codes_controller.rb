class Admin::ChannelCodesController < AdminController
  def index
    @channel_code = ChannelCode.new
    @channel_codes = ChannelCode.all
  end

  def create
    channel_code = ChannelCode.new(channel_code_params)
    if channel_code.save
      redirect_to admin_channel_codes_path, notice: 'success'
    else
      redirect_to admin_channel_codes_path, alert: channel_code.errors.full_messages.join(',')
    end
  end

  def edit
    @channel_code = ChannelCode.find(params[:id])
  end

  def update
    @channel_code = ChannelCode.find(params[:id])
    if @channel_code.update_attributes(channel_code_params.slice(:description))
      redirect_to admin_channel_codes_path, notice: 'success'
    else
      redirect_to admin_channel_codes_path, alert: @channel_code.errors.full_messages.join(',')
    end
  end

  private

  def channel_code_params
    params.require(:channel_code).permit(:code, :description)
  end
end
