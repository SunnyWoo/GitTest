# == Schema Information
#
# Table name: newsletters
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  delivery_at         :datetime
#  filter              :json
#  subject             :string(255)
#  content             :text
#  locale              :string(255)
#  mailgun_campaign_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#  state               :integer          default(0)
#

class Newsletter < ActiveRecord::Base
  include Logcraft::Trackable

  validates :subject, :content, :filter, presence: true
  validates :name, uniqueness: true, presence: true
  belongs_to :mailgun_campaign
  before_save :check_filter

  enum state: [:unsent, :sending, :sended]

  def create_mailgun_campaign
    mailgun_campaign = MailgunCampaign.create(name: name)
    res = update!(mailgun_campaign_id: mailgun_campaign.id)
    enqueue_send_mail if res
  end

  def enqueue_send_mail
    SendNewsletterWorker.perform_async(id)
    sending!
  end

  # send mail flow
  # 1. create mailgun campaign
  # 2. send mail
  def send_mail
    return create_mailgun_campaign if mailgun_campaign.nil?
    res = MailgunMailer.delay.send_message(id)
    create_activity(:send_success, message: res.to_s)
    sended!
  end

  def self.user_group
    {
      all:              'All',
      user:             '會員',
      subscription:     '訂閱電子報',
      bought:           '購買過產品的訪客',
      test:             'Test',
      customer_service: '客服'
    }
  end

  def filter_mail_to
    filter.join(',')
  end

  private

  def check_filter
    self.filter = filter.select {|f| f.present? } if filter
  end
end
