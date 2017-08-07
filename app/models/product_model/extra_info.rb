class ProductModel::ExtraInfo
  include Virtus.model

  attribute :width,            Float, default: 0
  attribute :height,           Float, default: 0
  attribute :dpi,              Integer, default: 300
  attribute :background_image, String
  attribute :overlay_image,    String
  attribute :shape,            String
  attribute :alignment_points, String
  attribute :padding_top,      Decimal, default: BigDecimal('0')
  attribute :padding_right,    Decimal, default: BigDecimal('0')
  attribute :padding_bottom,   Decimal, default: BigDecimal('0')
  attribute :padding_left,     Decimal, default: BigDecimal('0')
  attribute :background_color, String

  def self.dump(extra_info)
    extra_info.as_json
  end

  def self.load(hash)
    new(hash)
  end
end
