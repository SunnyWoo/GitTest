class Store::TextPhotoForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include Virtus.model

  attr_accessor :template

  delegate :template_image=, :template_image, :template_type, :template_type=,
           :product_width, :product_height, to: :template

  before_validation :set_min_font_size, unless: proc { |form| form.min_font_size.present? }

  attribute :font_name, String
  attribute :font_text, String
  attribute :max_font_size, Integer, default: 16
  attribute :min_font_size, Integer
  attribute :max_font_width, Integer, default: 0
  attribute :position_x, Decimal, default: 0
  attribute :position_y, Decimal, default: 0
  attribute :rotation, Decimal, default: 0
  attribute :color, String

  validates :position_x, :position_y, :rotation, numericality: true
  validates :max_font_width, numericality: { only_integer: true }
  validates :max_font_size, numericality: { only_integer: true, greater_than_or_equal_to: 12 }
  validates :min_font_size, numericality: { only_integer: true, greater_than_or_equal_to: 9 }
  validates :color, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/i, message: 'only for hex color' }
  validates :font_name, inclusion: { in: CommandP::Resources.fonts.map(&:name), message: 'Must be in CommanP::Resources.fonts' }
  validate :check_template_image_dimensions

  def initialize(template, attributes = {})
    @template = template
    super(attributes)
  end

  def save
    if valid?
      template.settings = attributes
      template.save
      true
    else
      false
    end
  end

  protected

  def set_min_font_size
    self.min_font_size = max_font_size * 3 / 4 if max_font_size.is_a?(Integer)
  end

  def check_template_image_dimensions
    return if (template_image.width - product_width).abs < 5 && (template_image.height - product_height).abs < 5
    suggest = "(#{product_width} x #{product_height})"
    errors.add(:template_image, I18n.t('store.forms.photo_only.errors.template_image_dimensions', suggest: suggest))
  end
end
