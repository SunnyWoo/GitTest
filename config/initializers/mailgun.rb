begin
  setting = Settings.mailgun
  $mailgun = Mailgun(api_key: setting.api_key, domain: setting.domain)
rescue
  raise "please setting mailgun api_key and domain"
end
