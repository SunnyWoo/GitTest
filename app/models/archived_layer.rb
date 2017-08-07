# == Schema Information
#
# Table name: archived_layers
#
#  id             :integer          not null, primary key
#  work_id        :integer
#  layer_type     :string(255)
#  orientation    :float            default(0.0)
#  scale_x        :float            default(1.0)
#  scale_y        :float            default(1.0)
#  color          :string(255)
#  transparent    :float            default(1.0)
#  font_name      :string(255)
#  font_text      :text
#  image          :string(255)
#  filter         :string(255)
#  filtered_image :string(255)
#  material_name  :string(255)
#  position_x     :float            default(0.0)
#  position_y     :float            default(0.0)
#  text_spacing_x :float            default(0.0)
#  text_spacing_y :float            default(0.0)
#  text_alignment :string(255)
#  position       :integer
#  image_meta     :json
#  created_at     :datetime
#  updated_at     :datetime
#  disabled       :boolean          default(FALSE), not null
#  mask_id        :integer
#

class ArchivedLayer < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  include Logcraft::Trackable
  include PreprocessImage
  include HasAttachment
  include SharedLayerMethods

  serialize :image_meta, Hashie::Mash.pg_json_serializer

  has_paper_trail

  belongs_to :work, class_name: 'ArchivedWork'
  belongs_to :mask, class_name: 'ArchivedLayer'
  has_many :masked_layers, -> { order('position ASC') }, class_name: 'ArchivedLayer', foreign_key: 'mask_id'

  accepts_nested_attributes_for :masked_layers
  has_attachment :image
  has_attachment :filtered_image

  mount_uploader :image, DefaultWithMetaUploader
  mount_uploader :filtered_image, DefaultWithMetaUploader
  carrierwave_meta_composed :image_meta, :image, image_version: [:width, :height, :md5sum]
  carrierwave_meta_composed :image_meta, :filtered_image, image_version: [:width, :height, :md5sum]
  preprocess_image :image, versions: %w(thumb)
  preprocess_image :filtered_image, versions: %w(thumb)

  scope :ordered, -> { order('position ASC') }
  scope :positive, -> { where('position >= 0') }
  scope :enabled, -> { where(disabled: false) }
  scope :root, -> { where(mask_id: nil) }

  validates :layer_type, inclusion: { in: Layer.layer_types.keys }

  Layer::ALL_LAYER_TYPES.each do |type|
    scope type, -> { where(layer_type: type) }
  end

  def builtin_shape?
    Layer::BUILTIN_SHAPES.include?(layer_type)
  end

  def cast_color
    color.gsub('0x', '#')
  end

  def color_with_alpha
    _, r, g, b = color.match(/0x(..)(..)(..)/).to_a
    format('rgba(%d, %d, %d, %f)', r.to_i(16), g.to_i(16), b.to_i(16), transparent)
  end

  def font_path
    return unless font_name.present?
    font = CommandP::Resources.fonts[font_name] ||
           CommandP::Resources.fonts['Heiti TC']
    font.local_file
  end

  def material_path
    "#{Settings.graphic_library_path}#{layer_type}/#{material_name}.svg"
  end

  def photo?
    layer_type == 'photo'
  end

  def camera?
    layer_type == 'camera'
  end

  def mask?
    layer_type == 'mask'
  end

  def general_layers?
    !mask? && !mask
  end

  def mask_image
    @mask_image ||= Mask.find_by!(material_name: material_name).image
  end
end
