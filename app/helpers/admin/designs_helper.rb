module Admin::DesignsHelper
  def dimension_tag(width, height)
    "#{width.round}x#{height.round}"
  end
end
