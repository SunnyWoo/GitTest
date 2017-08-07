class ChangePriceWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(event_id)
    event = ChangePriceEvent.find(event_id)
    begin
      ChangePriceService.new(event_id).execute
      event.finish!
    rescue => error
      event.failure!
      unless Rails.env.development?
        Rollbar.error(error)
        SlackNotifier.send_msg("批次調價失敗 change_price_event_id: #{event_id}")
      end
    end
  end
end
