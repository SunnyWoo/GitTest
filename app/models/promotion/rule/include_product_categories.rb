class Promotion::Rule::IncludeProductCategories
  include Promotion::Rule::ActsAsItemRule

  def initialize(members, quantity, options = {})
    @members = Array(members).uniq
    @quantity = quantity.to_i
    @options = options
    raise ArgumentError if @members.empty? && !options[:all]
    raise ArgumentError if @quantity.zero?
  end

  private

  def judgement?(unit)
    @options[:all] || unit.product.category.in?(@members)
  end
end
