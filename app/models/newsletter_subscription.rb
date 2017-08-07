# == Schema Information
#
# Table name: newsletter_subscriptions
#
#  id           :integer          not null, primary key
#  email        :string(255)
#  locale       :string(255)
#  is_enabled   :boolean          default(TRUE)
#  created_at   :datetime
#  updated_at   :datetime
#  country_code :string(255)
#

class NewsletterSubscription < ActiveRecord::Base
  include ActsAsIsEnabled
  validates :email, email: true, uniqueness: true

  before_save :downcase_email
  after_create :enqueue_post_to_mailgun_mailing_list

  def enqueue_post_to_mailgun_mailing_list
    MailgunAddMailingListWorker.perform_async(email, 'all')
    MailgunAddMailingListWorker.perform_async(email, 'subscription')
  end

  private

  def downcase_email
    email.downcase!
  end
end
