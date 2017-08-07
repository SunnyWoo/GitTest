# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  title      :string(255)
#  body       :text
#  mail_to    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  order_no   :string(255)
#

class Message < ActiveRecord::Base
  belongs_to :user

  scope :ordered, -> { order('created_at DESC') }

  def mail=(mail)
    self.attributes = {
      title: mail.subject,
      body: mail.html_part.body.to_s,
      mail_to: mail.to.join(', ')
    }
  end

  def resend
    MessageMailer.resend(self).deliver
  end
end
