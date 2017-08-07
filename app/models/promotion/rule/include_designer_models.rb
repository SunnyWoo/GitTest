class Promotion::Rule::IncludeDesignerModels
  include Promotion::Rule::ActsAsItemRule

  def initialize(designers, models, quantity)
    @designers = designers
    @models = models
    @quantity = quantity.to_i
    raise ArgumentError if @designers.empty?
    raise ArgumentError if @models.empty?
    raise ArgumentError if @quantity.zero?
  end

  private

  def judgement?(unit)
    return false unless unit.itemable.respond_to?(:user)
    unit.product.in?(@models) && unit.itemable.user.in?(@designers)
  end
end
