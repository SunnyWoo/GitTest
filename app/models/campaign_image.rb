# == Schema Information
#
# Table name: campaign_images
#
#  id              :integer          not null, primary key
#  campaign_id     :integer
#  key             :string(255)
#  file            :string(255)
#  desc            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  link            :string(255)
#  open_in_new_tab :boolean          default(FALSE)
#

class CampaignImage < ActiveRecord::Base
  belongs_to :campaign
  validates :link, format: { with: URI.regexp }, if: proc { |campaign_image| campaign_image.link.present? }
  mount_uploader :file, DefaultWithMetaUploader
  KEY_LIST = %w(kv_bg kv_tc m_kv_bg m_kv_tc about m_about about_bg m_about_bg sign fb_share artwork)

  def self.render_image(key)
    image = find_by(key: key)
    image.file.url if image
  end

  def self.render_images(key)
    images = where(key: key)
    images.map { |i| i.file.url } if images
  end
end
