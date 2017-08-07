module HasGoogleCalendar
  protected

  def enable_google_calendar?
    Settings.try(:google).try(:calendar).try(:client_id).present?
  end
end
