class GoogleCalendar
  def initialize
    @client_id, @client_secret, @calendar_id, @refresh_token = Settings.google.calendar.values_at('client_id', 'client_secret', 'calendar_id', 'refresh_token') if Settings.google.try(:calendar).try(:client_id)
    @redirect_url = 'urn:ietf:wg:oauth:2.0:oob'
  end

  def client
    @client ||= (
      api_client = Google::Calendar.new(client_id:     @client_id,
                                        client_secret: @client_secret,
                                        calendar:      @calendar_id,
                                        redirect_url:  @redirect_url
                                       )
      api_client.login_with_refresh_token(@refresh_token)
      api_client
    )
  end
end
