# == Schema Information
#
# Table name: cp_resources
#
#  id            :integer          not null, primary key
#  version       :integer
#  aasm_state    :string
#  publish_at    :datetime
#  list_urls     :json
#  small_package :string
#  large_package :string
#  memo          :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CpResource < ActiveRecord::Base
  include AASM
  aasm do
    state :draft, initial: true
    state :published
    state :pulled

    event :publish do
      transitions from: [:draft, :pulled], to: :published
      after do
        update_list_urls
        self.publish_at = Time.zone.now
        save!
      end
    end

    event :pull do
      transitions from: :published, to: :pulled
    end
  end

  def update_list_urls
    tmp_urls = if Region.china?
                  AssetPackage::QiniuService.new.list_urls(version)
                else
                  AssetPackage::AwsS3Service.new.list_urls(version).to_a
                end
    return unless tmp_urls
    self.list_urls = tmp_urls
  end

  # for daily report ends_at
  def ends_at
    self.next.present? ? self.next.publish_at : Time.zone.now
  end

  def next
    CpResource.published.where("id > ?", id).first
  end

  def self.new_version
    # 完成 Model 前最後一個版號
    magic_number = 12
    v = CpResource.order('version desc').first.try(:version) || magic_number
    v+1
  end
end
