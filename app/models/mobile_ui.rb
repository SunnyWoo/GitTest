# == Schema Information
#
# Table name: mobile_uis
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :string(255)
#  template    :string(255)
#  image       :string(255)
#  priority    :integer          default(1)
#  start_at    :date
#  end_at      :date
#  is_enabled  :boolean          default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  default     :boolean          default(FALSE)
#

class MobileUi < ActiveRecord::Base
  include ActsAsIsEnabled
  validates :title, :template, :image,
            :start_at, :end_at, presence: true
  scope :available, -> { where('start_at <= :today and end_at >= :today', today: Date.today) }
  scope :hotest_enabled, -> { enabled.order('priority DESC, created_at DESC') }
  scope :default, -> { where(default: true).order('priority DESC, created_at DESC') }

  mount_uploader :image, MobileUiUploader
end
