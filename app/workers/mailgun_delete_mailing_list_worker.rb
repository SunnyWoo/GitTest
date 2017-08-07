class MailgunDeleteMailingListWorker
  include Sidekiq::Worker
   sidekiq_options retry: false

  def perform(email, mailing_list= 'all')
    MailgunDeleteMailingListService.new(email, mailing_list: mailing_list).execute
  end
end