# == Schema Information
#
# Table name: impositions
#
#  id                       :integer          not null, primary key
#  model_id                 :integer
#  paper_width              :float
#  paper_height             :float
#  definition               :json
#  created_at               :datetime
#  updated_at               :datetime
#  sample                   :string(255)
#  rotate                   :integer
#  type                     :string(255)
#  template                 :string(255)
#  demo                     :boolean          default(FALSE), not null
#  file                     :string(255)
#  flip                     :boolean          default(FALSE)
#  flop                     :boolean          default(FALSE)
#  include_order_no_barcode :boolean          default(FALSE)
#

class Imposition < ActiveRecord::Base
  include Imposition::Shared

  attr_accessor :remove_sample, :skip_build_sample
  VERSIONS = %i(flip flop).freeze

  mount_uploader :template, DefaultUploader
  has_paper_trail

  serialize :definition, Hashie::Mash.pg_json_serializer

  belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id

  delegate :width, :height, :dpi, to: :product, prefix: true

  after_save :enqueue_build_sample, unless: :skip_build_sample

  scope :demo, -> { where(demo: true) }
  scope :production, -> { where(demo: false) }

  def enqueue_build_sample
    update(remove_sample: true, skip_build_sample: true)
    ImpositionSampleBuilder.perform_async(id)
  end

  def slice_size
    fail 'Not yet implemented.'
  end

  def build_printable(_items)
    fail 'Not yet implemented.'
  end

  def build_sample
    fail 'Not yet implemented.'
  end
end
