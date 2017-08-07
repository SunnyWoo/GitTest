class SendNewsletterWorker
  include Sidekiq::Worker

  def perform(id)
    newsletter = Newsletter.find(id)
    newsletter.send_mail
  end
end