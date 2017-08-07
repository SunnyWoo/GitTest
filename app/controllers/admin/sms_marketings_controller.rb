class Admin::SmsMarketingsController < AdminController
  def show
    @mobile_count = User.where.not(mobile: nil, confirmed_at: nil).count
    @marketing_sms_logs = Logcraft::Activity.where(key: :mobile_send_marketing)
                                            .order('created_at desc')
                                            .page(params[:page])
                                            .per_page(15)
  end

  def preview
  end

  def send_sms
    MobileMarketingSmsSender.perform_async(current_admin.id, params[:marketing_sms])
    redirect_to admin_sms_marketing_path, notice: '短訊已加入排程，將陸續發送！'
  end
end
