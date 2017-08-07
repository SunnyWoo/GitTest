module GoogleCalendar::Event
  @calendar = GoogleCalendar.new
  class << self
    def create(type:, title:, start_date:, end_date:)
      event = @calendar.client.create_event do |e|
        e.title      = event_name(type, title)
        e.start_time = start_date
        e.end_time   = end_date
      end
      event.id
    end

    def update(event_id:, type:, title:, start_date:, end_date:)
      event = @calendar.client.find_or_create_event_by_id(event_id) do |e|
        e.title      = event_name(type, title)
        e.start_time = start_date
        e.end_time   = end_date
      end
      event.id
    end

    def destroy_by_id(event_id)
      event = @calendar.client.find_or_create_event_by_id(event_id)
      event.delete
    end

    private

    def event_name(type, title)
      "【#{type}】#{title}"
    end
  end
end
