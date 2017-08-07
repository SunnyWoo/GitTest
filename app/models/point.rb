class Point
  include ActiveModel::Model

  attr_accessor :x, :y

  def x=(x)
    @x = x.to_f
  end

  def y=(y)
    @y = y.to_f
  end
end
