class MailgunMailingListService
  def initialize(email, args = {})
    @email = email
    @mailing_list = args.delete(:mailing_list) || 'all'
    @subscribed = args.delete(:subscribed) || 'yes'
    @vars = args.delete(:vars) || {}
  end

  def execute
    return if Region.china? || @email.match(User::GUEST_EMAIL_PATTERN)
    begin
      alias_address = Settings.mailgun.mailing_list[@mailing_list]
      $mailgun.list_members(alias_address).add(@email,
                                               vars: @vars.to_json,
                                               subscribed: @subscribed)
    rescue => e
      Rails.logger.error("Mailgun mailing list add list member mailing_list:#{@mailing_list} error: #{e}")
    end
  end
end
