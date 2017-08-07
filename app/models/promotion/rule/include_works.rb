class Promotion::Rule::IncludeWorks
  include Promotion::Rule::ActsAsItemRule

  def initialize(members, quantity)
    @member_ids = Array(members).uniq.map(&:id)
    @quantity = quantity.to_i
    raise ArgumentError if @member_ids.empty?
    raise ArgumentError if @quantity.zero?
  end

  private

  def judgement?(unit)
    work_id = unit.item.itemable.try(:original_work_id) || unit.item.itemable.id
    work_id.in?(@member_ids)
  end
end
