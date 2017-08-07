class MarketingReportWorker
  include Sidekiq::Worker

  def perform(admin_id, args = {})
    result = MarketingReport::GenerateService.new(args).execute
    admin = Admin.find(admin_id)
    if result.success?
      ReportMailer.marketing_reports(file: result.payload, user: admin).deliver
    else
      SlackNotifier.send_msg "行銷報表: #{args.symbolize_keys[:type]} 製作失敗, 錯誤訊息: #{result.error.message}"
    end
  end
end
