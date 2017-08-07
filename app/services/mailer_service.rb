class MailerService
  def self.domain
    Region.china? ? Settings.send_cloud.domain : Settings.mailgun.domain
  end

  def self.from
    "#{I18n.t('site.name', locale: Region.default_locale)} <no-reply@#{domain}>"
  end
end
