class CreateMailgunCampaignWorker
  include Sidekiq::Worker

  def perform(id)
    mailgun_campaign = MailgunCampaign.find(id)
    mailgun_campaign.create_to_mailgun
  end
end