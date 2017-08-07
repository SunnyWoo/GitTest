# == Schema Information
#
# Table name: file_gateways
#
#  id           :integer          not null, primary key
#  type         :string(255)
#  factory_id   :integer
#  connect_info :hstore
#  created_at   :datetime
#  updated_at   :datetime
#

class FileGateway < ActiveRecord::Base
  include Logcraft::Trackable

  belongs_to :factory

  validates_presence_of :factory_id

  def upload
    raise 'Not Implemented'
  end

  def batch_upload
    raise 'Not Implemented'
  end
end
