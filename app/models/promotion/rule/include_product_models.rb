class Promotion::Rule::IncludeProductModels
  include Promotion::Rule::ActsAsItemRule

  def initialize(members, quantity)
    @members = Array(members).uniq
    @quantity = quantity.to_i
    raise ArgumentError if @members.empty?
    raise ArgumentError if @quantity.zero?
  end

  private

  def judgement?(unit)
    unit.product.in? @members
  end
end
