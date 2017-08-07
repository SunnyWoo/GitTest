class AddGoogleCalendarIdToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :google_calendar_id, :string
  end
end
