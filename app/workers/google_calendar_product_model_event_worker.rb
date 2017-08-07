class GoogleCalendarProductModelEventWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  sidekiq_options queue: :google if Region.china?

  def perform(content, time)
    GoogleCalendar::Event.create(type:      'ProductModel',
                                 title:      content,
                                 start_date: Time.zone.parse(time),
                                 end_date:   Time.zone.parse(time) + (60 * 60))
  end
end
