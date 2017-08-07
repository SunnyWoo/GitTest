class MailgunAddMailingListWorker
  include Sidekiq::Worker
   sidekiq_options retry: false

  def perform(email, mailing_list= 'all')
    MailgunMailingListService.new(email, mailing_list: mailing_list).execute
  end
end