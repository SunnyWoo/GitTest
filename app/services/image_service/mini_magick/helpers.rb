module ImageService::MiniMagick::Helpers
  def to_percent(value)
    '%.2f%' % (value * 100)
  end

  def to_absolute_geometry(x, y)
    "%dx%d" % [x.abs, y.abs]
  end

  def to_percent_geometry(x, y)
    "#{to_percent(x)}x#{to_percent(y)}"
  end

  def to_position(x, y)
    "%+d%+d" % [x.to_i, y.to_i]
  end

  def to_blend_value(transparent)
    (100 * transparent).to_i
  end
end
