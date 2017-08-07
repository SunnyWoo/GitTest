# == Schema Information
#
# Table name: work_templates
#
#  id               :integer          not null, primary key
#  model_id         :integer
#  background_image :string(255)
#  overlay_image    :string(255)
#  aasm_state       :string(255)
#  masks            :json
#  created_at       :datetime
#  updated_at       :datetime
#

class WorkTemplate < ActiveRecord::Base
  include AASM

  has_many :works
  belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id

  serialize :masks, WorkTemplateMask::ArraySerializer

  mount_uploader :background_image, WorkTemplateUploader
  mount_uploader :overlay_image, WorkTemplateUploader

  scope :published, -> { where(aasm_state: :published) }

  aasm do
    state :draft
    state :published
    state :trashed
  end

  def serialize_masks(masks_params)
    serialize_masks = []
    masks_params.each do |mask_params|
      serialize_masks << WorkTemplateMask.new(mask_params)
    end
    self.masks = serialize_masks
    save
  end
end
