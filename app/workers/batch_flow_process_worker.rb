class BatchFlowProcessWorker
  include Sidekiq::Worker

  def perform(batch_flow_id)
    batch_flow = BatchFlow.find(batch_flow_id)
    origin_locale = I18n.locale
    I18n.locale = batch_flow.locale
    begin
      batch_flow.process!
      batch_flow.finish!
    rescue => error
      Rollbar.error(error) unless Rails.env.development?
      batch_flow.failure!(error: error)
    ensure
      I18n.locale = origin_locale
    end
  end
end
