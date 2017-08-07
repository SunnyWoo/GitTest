# == Schema Information
#
# Table name: preview_composers
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  model_id    :integer
#  layers      :text
#  created_at  :datetime
#  updated_at  :datetime
#  key         :string(255)
#  available   :boolean          default(FALSE), not null
#  position    :integer
#  template_id :integer
#

class PreviewComposer < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord

  acts_as_list scope: :model_id

  belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id
  belongs_to :template, class_name: 'ProductTemplate', foreign_key: :template_id
  has_many :samples, class_name: 'PreviewSample'

  after_commit :rebuild_samples, on: [:create, :update]

  validates :key, uniqueness: { scope: [:model_id, :template_id], allow_blank: true },
                  presence: { if: :available? }

  default_scope { order('position asc') }
  scope :available, -> { where(available: true) }

  def sample_works
    product.standardized_works.order('created_at DESC').limit(3)
  end

  def rebuild_samples
    samples.destroy_all
    PreviewSamplesBuilder.perform_async(id, updated_at.to_s)
  end
end
