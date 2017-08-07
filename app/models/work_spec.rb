# == Schema Information
#
# Table name: work_specs
#
#  id                                        :integer          not null, primary key
#  model_id                                  :integer
#  name                                      :string(255)
#  description                               :text
#  width                                     :float
#  height                                    :float
#  dpi                                       :integer          default(300)
#  created_at                                :datetime
#  updated_at                                :datetime
#  background_image                          :string(255)
#  overlay_image                             :string(255)
#  shape                                     :string(255)
#  alignment_points                          :string(255)
#  padding_top                               :decimal(8, 2)    default(0.0), not null
#  padding_right                             :decimal(8, 2)    default(0.0), not null
#  padding_bottom                            :decimal(8, 2)    default(0.0), not null
#  padding_left                              :decimal(8, 2)    default(0.0), not null
#  background_color                          :string(255)      default("white"), not null
#  variant_id                                :integer
#  dir_name                                  :string
#  placeholder_image                         :string
#  enable_white                              :boolean          default(FALSE)
#  auto_imposite                             :boolean          default(FALSE)
#  watermark                                 :string
#  print_image_mask                          :string
#  enable_composite_with_horizontal_rotation :boolean          default(FALSE)
#  create_order_image_by_cover_image         :boolean          default(FALSE)
#  enable_back_image                         :boolean          default(FALSE)
#

class WorkSpec < ActiveRecord::Base
  SHAPES = %w(rectangle ellipse).freeze
  ALIGNMENT_POINTS = %w(none solo_bot).freeze
  BACKGROUND_COLORS = %w(none white black).freeze

  strip_attributes only: %i(name)
  has_paper_trail

  belongs_to :variant

  # has_one :imposition, foreign_key: :spec_id
  # has_many :preview_composers, foreign_key: :spec_id
  # has_many :works, foreign_key: :spec_id

  validates :name, :width, :height, :dpi, presence: true
  validates :shape, inclusion: SHAPES
  validates :alignment_points, inclusion: ALIGNMENT_POINTS
  validates :background_color, inclusion: BACKGROUND_COLORS
  validate :check_print_image_mask_size

  mount_uploader :background_image, DefaultUploader
  mount_uploader :overlay_image, DefaultUploader
  mount_uploader :placeholder_image, DefaultUploader
  mount_uploader :watermark, DefaultUploader
  mount_uploader :print_image_mask, DefaultUploader

  def width(unit = :mm)
    case unit
    when :px   then super() * 2.84
    when :mm   then super()
    when :inch then super() / 25.4
    else            super()
    end
  end

  def height(unit = :mm)
    case unit
    when :px then   super() * 2.84
    when :mm then   super()
    when :inch then super() / 25.4
    else            super()
    end
  end

  def dpi_width
    width(:inch) * dpi.to_f
  end

  def dpi_height
    height(:inch) * dpi.to_f
  end

  def name_with_model
    "#{model.name} #{name}"
  end

  def check_print_image_mask_size
    return if print_image_mask.blank?
    expect_width = dpi_width.to_i
    expect_height = dpi_height.to_i
    actual_width, actual_height = print_image_mask.send(:get_dimensions)
    return if actual_width == expect_width && actual_height == expect_height
    errors.add(:print_image_mask, "上傳的遮罩圖大小為 #{actual_width}x#{actual_height}, 但產品圖的大小為 #{expect_width}x#{expect_height}")
  end
end
