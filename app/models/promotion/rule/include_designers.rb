class Promotion::Rule::IncludeDesigners
  include Promotion::Rule::ActsAsItemRule

  def initialize(members, quantity)
    @members = Array(members).uniq
    @quantity = quantity.to_i
    raise ArgumentError if @members.empty?
    raise ArgumentError if @quantity.zero?
  end

  private

  def judgement?(unit)
    return false unless unit.itemable.respond_to?(:user)
    unit.itemable.user.in? @members
  end
end
