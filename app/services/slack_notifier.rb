class SlackNotifier
  def self.send_msg(msg)
    webhook_url = SiteSetting.by_key('SlackNotifierWebhookUrl')
    payload = { text: "[#{Region.region}][#{Rails.env}] #{msg}" }
    HTTParty.send(:post, webhook_url, body: { payload: payload.to_json }) if webhook_url
  end
end
