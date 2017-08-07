class Store::PhotoOnlyForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :template, :template_type

  delegate :template_image=, :template_image, :template_type, :template_type=,
           :product_width, :product_height, to: :template

  validate :check_template_image_dimensions

  def initialize(template, attributes = {})
    @template = template
    super(attributes)
  end

  def save
    if valid?
      template.settings = {}
      template.save
      true
    else
      false
    end
  end

  protected

  def check_template_image_dimensions
    return if (template_image.width - product_width).abs < 5 && (template_image.height - product_height).abs < 5
    suggest = "(#{product_width} x #{product_height})"
    errors.add(:template_image, I18n.t('store.forms.photo_only.errors.template_image_dimensions', suggest: suggest))
  end
end
