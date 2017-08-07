class GoogleCalendarDeleteEventWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  sidekiq_options queue: :google if Region.china?

  def perform(event_id)
    GoogleCalendar::Event.destroy_by_id(event_id)
  end
end
