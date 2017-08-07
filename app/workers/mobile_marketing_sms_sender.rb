class MobileMarketingSmsSender
  include Sidekiq::Worker
  # 设置不重试，防止发送中途失败而进行重试
  sidekiq_options retry: false

  def perform(admin_id, options)
    admin = Admin.find(admin_id)
    Mobile::SendMarketingService.new(admin, options).execute
  end
end
