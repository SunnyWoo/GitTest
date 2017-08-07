# == Schema Information
#
# Table name: batch_flow_attachments
#
#  id            :integer          not null, primary key
#  batch_flow_id :integer          not null
#  name          :string(255)      not null
#  file          :string(255)      not null
#  created_at    :datetime
#  updated_at    :datetime
#

class BatchFlowAttachment < ActiveRecord::Base
  belongs_to :batch_flow
  mount_uploader :file, DeliveryFileUploader

  def title
    I18n.t(name, scope: 'print.batch_flow.attachment.title')
  end
end
