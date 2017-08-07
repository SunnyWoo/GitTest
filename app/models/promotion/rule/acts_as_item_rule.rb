module Promotion::Rule::ActsAsItemRule
  attr_reader :quantity

  def conformed?(serial_units)
    serial_units.count { |unit| judgement?(unit) } >= quantity
  end

  # coupon不可與其他 promotion 同時使用时活动不可以用
  def conformed_by_order?(order)
    return false if order.embedded_coupon.try(:is_not_include_promotion)
    conformed?(order.to_serial_units)
  end

  def extract(serial_units)
    n = 0
    ans = []
    serial_units.each do |unit|
      if n < quantity && judgement?(unit)
        n += 1
        ans << unit
      end
    end
    ans.each { |x| serial_units.delete(x) }
    ans
  end

  private

  def judgement?(_unit)
    raise NotImplementedError, 'subclass responsiblity'
  end
end
