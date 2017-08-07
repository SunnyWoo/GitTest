# == Schema Information
#
# Table name: layers
#
#  id                         :integer          not null, primary key
#  work_id                    :integer
#  orientation                :float            default(0.0)
#  scale_x                    :float            default(1.0)
#  scale_y                    :float            default(1.0)
#  color                      :string(255)
#  transparent                :float            default(1.0)
#  font_name                  :string(255)
#  font_text                  :text
#  image                      :string(255)
#  material_name              :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  layer_type                 :integer
#  layer_no                   :string(255)
#  position_x                 :float            default(0.0)
#  position_y                 :float            default(0.0)
#  text_spacing_x             :integer
#  text_spacing_y             :integer
#  text_alignment             :string(255)
#  filter_type                :integer
#  position                   :integer
#  filter                     :string(255)      default("0")
#  filtered_image             :string(255)
#  uuid                       :string(255)
#  image_meta                 :text
#  disabled                   :boolean          default(FALSE), not null
#  attached_image_id          :integer
#  attached_filtered_image_id :integer
#  mask_id                    :integer
#

require 'find'

class Layer < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  include HasUniqueUUID
  include Logcraft::Trackable
  include PreprocessImage
  include HasAttachment
  include SharedLayerMethods

  attr_accessor :image_aid, :filtered_image_aid

  serialize :image_meta, OpenStruct

  has_paper_trail
  has_attachment :image
  has_attachment :filtered_image

  belongs_to :work
  belongs_to :attached_image, class_name: 'Attachment'
  belongs_to :attached_filtered_image, class_name: 'Attachment'
  belongs_to :mask, class_name: 'Layer'
  has_many :masked_layers, -> { order('position ASC') }, class_name: 'Layer', foreign_key: 'mask_id'

  accepts_nested_attributes_for :masked_layers

  mount_uploader :image, LayerUploader
  mount_uploader :filtered_image, LayerUploader
  process_in_background :image
  process_in_background :filtered_image

  carrierwave_meta_composed :image_meta, :image, image_version: [:width, :height, :md5sum]
  carrierwave_meta_composed :image_meta, :filtered_image, image_version: [:width, :height, :md5sum]
  preprocess_image :image, versions: %w(thumb)
  preprocess_image :filtered_image, versions: %w(thumb)

  validates :layer_type, :position, presence: true

  validate :validates_name_should_fit_library_for_builtin_shapes, if: :builtin_shape?
  validate :validates_name_should_fit_library_for_builtin_vectors, if: :builtin_vector?
  validate :validates_name_should_fit_library_for_third_party_assets, if: :uses_thrid_party_asset?
  validates :scale_x, :scale_y, :position_x, :position_y, finity_number: true
  validates :font_path, presence: { if: :text? }
  validate :validates_svg_should_be_uploaded, if: :svg_layer?

  after_create :create_create_activity
  # TODO: 加上 Soft Delete 功能
  # 只有在 layer 存在的情況下才能建立，因此先假設 Destroy 一定成功來建立一個 Activity，這是一個 workaround
  before_destroy :create_destroy_activity

  GRAPHIC_LIBRARY_PATH = 'app/assets/images/graphic_library/'.freeze

  enum layer_type: [:camera, :photo, :background_color, :shape, :crop, :line,
                    :sticker, :texture, :typography, :text, :lens_flare,
                    :spot_casting, :spot_casting_text, :varnishing, :bronzing,
                    :varnishing_typography, :bronzing_typography,
                    :sticker_asset, :coating_asset, :foiling_asset, :mask, :frame, :fake, :colorsticker]

  NON_COMMANDP_RESOURCE_TYPES = %w(camera photo background_color lens_flare spot_casting spot_casting_text text
                                   varnishing bronzing sticker_asset coating_asset foiling_asset mask fake).freeze
  COMMANDP_RESOURCE_TYPES = (layer_types.keys - NON_COMMANDP_RESOURCE_TYPES).freeze

  STICKER_TYPES = %w(background_color shape line sticker texture typography colorsticker frame).freeze

  scope :positive, -> { where('position >= 0') }
  scope :enabled, -> { where(disabled: false) }
  scope :root, -> { where(mask_id: nil) }

  def cast_color
    color.gsub('0x', '#')
  end

  def color_with_alpha
    _, r, g, b = color.match(/0x(..)(..)(..)/).to_a
    format('rgba(%d, %d, %d, %f)', r.to_i(16), g.to_i(16), b.to_i(16), transparent)
  end

  def layer_type_key
    self['layer_type']
  end

  # Public 對改名字的 material_name 欄位做的 setter
  #
  # Returns nothing
  def name=(name)
    self[:material_name] = name
  end

  # Public 尋找 Layer 使用的字型路徑
  #
  # Returns String
  def font_path
    return unless font_name.present?
    font = CommandP::Resources.fonts[font_name] ||
           CommandP::Resources.fonts['Heiti TC']
    font.local_file
  end

  ALLOWED_TEXT_ALIGNMENT = %w(0 1 2 Left Center Right).freeze

  def text_alignment=(value)
    super(normalize_text_alignment(value))
  end

  NORMALIZE_TABLE = {
    '0' => 'Left',
    '1' => 'Center',
    '2' => 'Right'
  }.freeze

  def normalize_text_alignment(value)
    case
    when NORMALIZE_TABLE.value?(value) then value
    when NORMALIZE_TABLE[value]        then NORMALIZE_TABLE[value]
    else                                    'Left'
    end
  end

  def archived_attributes
    {
      layer_type: layer_type,
      orientation: orientation,
      scale_x: scale_x,
      scale_y: scale_y,
      color: color,
      transparent: transparent,
      font_name: font_name,
      font_text: font_text,
      image: image.file,
      filter: filter,
      filtered_image: filtered_image.file,
      material_name: material_name,
      position_x: position_x,
      position_y: position_y,
      text_spacing_x: text_spacing_x,
      text_spacing_y: text_spacing_y,
      text_alignment: text_alignment,
      position: position,
      masked_layers_attributes: masked_layers.map(&:archived_attributes)
    }
  end

  def material_path
    "#{Settings.graphic_library_path}#{layer_type}/#{material_name}.svg"
  end

  def image
    attached_image.try(:file) || super
  end

  def filtered_image
    attached_filtered_image.try(:file) || super
  end

  def general_layers?
    !mask? && !mask
  end

  def mask_image
    @mask_image ||= Mask.find_by!(material_name: material_name).image
  end

  private

  BUILTIN_SHAPES = %w(shape crop line sticker texture typography frame colorsticker).freeze
  BUILTIN_VECTORS = %w(varnishing_typography bronzing_typography).freeze
  THIRD_PARTY_ASSETS = %w(sticker_asset coating_asset foiling_asset).freeze
  ALL_LAYER_TYPES = (BUILTIN_SHAPES + BUILTIN_VECTORS + THIRD_PARTY_ASSETS).freeze

  def builtin_shape?
    BUILTIN_SHAPES.include?(layer_type)
  end

  def builtin_vector?
    BUILTIN_VECTORS.include?(layer_type)
  end

  def uses_thrid_party_asset?
    THIRD_PARTY_ASSETS.include?(layer_type)
  end

  def validates_name_should_fit_library_for_builtin_shapes
    names = Dir.glob("#{Settings.graphic_library_path}#{layer_type}/{*.png}").map do |file|
      File.basename(file, '@2x.png')
    end
    errors[:material_name] << "material name is not included in #{names}" unless names.include?(material_name)
  end

  def validates_name_should_fit_library_for_builtin_vectors
    names = Dir.glob("#{Settings.graphic_library_path}#{layer_type}/{*.svg}").map do |file|
      File.basename(file, '.svg')
    end
    errors[:material_name] << "material name is not included in #{names}" unless names.include?(material_name)
  end

  def validates_name_should_fit_library_for_third_party_assets
    return if Asset.exists?(uuid: material_name)
    errors[:material_name] << "couldn't find asset with given uuid #{material_name}"
  end

  def create_create_activity
    create_activity(:create, work_id: work.try(:id))
  end

  def create_destroy_activity
    create_activity(:destroy, work_id: work.try(:id))
  end

  def svg_layer?
    varnishing? || bronzing?
  end

  def validates_svg_should_be_uploaded
    if filtered_image.blank?
      errors.add(:filtered_image, :blank) and return
    end
    unless filtered_image.svg?
      errors.add(:filtered_image, :invalid) and return
    end
  end
end
