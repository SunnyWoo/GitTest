class MailgunDeleteMailingListService
  def initialize(email, args = {})
    @email = email
    @mailing_list = args.delete(:mailing_list)
  end

  def execute
    begin
      alias_address = Settings.mailgun.mailing_list[@mailing_list]
      $mailgun.list_members(alias_address).remove(@email)
    rescue => e
      Rails.logger.error("Mailgun mailing list delete list member mailing_list:#{@mailing_list} error: #{e}")
    end
  end
end