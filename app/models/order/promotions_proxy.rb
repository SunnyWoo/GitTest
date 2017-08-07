class Order::PromotionsProxy
  include Enumerable

  attr_reader :records
  delegate :each, :size, to: :records

  def self.build(order)
    promotions = order.adjustments.map do |adj|
      adj.source if adj.source.is_a?(Promotion)
    end.compact.uniq
    new(promotions)
  end

  def initialize(promotions)
    @records = promotions
  end

  def recent_ending
    self.class.new(select(&:started?).select(&:ends_at).sort_by(&:ends_at))
  end
end
