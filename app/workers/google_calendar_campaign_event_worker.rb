class GoogleCalendarCampaignEventWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  sidekiq_options queue: :google if Region.china?

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)

    params = {
      type:      'Campaign',
      title:      campaign.title,
      start_date: Time.zone.parse(campaign.g_start_at),
      end_date:   Time.zone.parse(campaign.g_end_at)
    }

    google_calendar_id = if campaign.google_calendar_id.nil?
                           GoogleCalendar::Event.create(params)
                         else
                           params[:event_id] = campaign.google_calendar_id
                           GoogleCalendar::Event.update(params)
                         end
    campaign.update!(google_calendar_id: google_calendar_id) if campaign.google_calendar_id != google_calendar_id
  end
end
