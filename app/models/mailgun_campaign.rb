# == Schema Information
#
# Table name: mailgun_campaigns
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  campaign_id       :string(255)
#  is_mailgun_create :boolean          default(FALSE)
#  report            :json
#  created_at        :datetime
#  updated_at        :datetime
#

class MailgunCampaign < ActiveRecord::Base
  include Logcraft::Trackable

  validates_presence_of :name
  validates :campaign_id, uniqueness: true

  before_validation :check_campaign_id
  after_create  :enqueue_create_to_mailgun

  serialize :report, Hashie::Mash.pg_json_serializer

  def check_campaign_id
    self.campaign_id ||= UUIDTools::UUID.timestamp_create.to_s
  end

  def enqueue_create_to_mailgun
    CreateMailgunCampaignWorker.perform_async(id)
  end

  def create_to_mailgun
    setting = Settings.mailgun
    begin
      $mailgun.campaigns.create(name, campaign_id)
      update! is_mailgun_create: true
    rescue => e
      logger.info "Create MailgunCampaign id:#{id} error: #{e.to_s}"
      create_activity(:create_to_mailgun_error, message: e.to_s)
    end
  end

  def get_report
    begin
      report = $mailgun.campaigns.find(campaign_id)
      update! report: report
    rescue => e
      create_activity(:get_report_error, message: e.to_s)
    end
  end
end
