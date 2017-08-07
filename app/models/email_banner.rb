# == Schema Information
#
# Table name: email_banners
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  file       :string(255)
#  starts_at  :datetime
#  ends_at    :datetime
#  is_default :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class EmailBanner < ActiveRecord::Base
  validates :starts_at, :ends_at, :name, :file, presence: true
  mount_uploader :file, EmailBannerUploader

  def self.available
    time = Time.zone.now
    where("(starts_at <= ? AND ends_at >= ? AND \"is_default\" = 'f') OR (\"is_default\" = 't')", time, time).
    order('id DESC').first
  end
end
