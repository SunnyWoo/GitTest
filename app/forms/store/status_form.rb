class Store::StatusForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :price_tier_id, :special_price_tier_id, :aasm_state
  attr_reader :template

  validates :price_tier_id, presence: true
  validates :aasm_state, inclusion: { in: ProductTemplate.aasm.states.map(&:name).map(&:to_s) }

  def initialize(template, attrs = {})
    @template = template
    super(attrs)
  end

  def save
    if valid?
      template.update price_tier_id: price_tier_id, special_price_tier_id: special_price_tier_id, aasm_state: aasm_state
    else
      false
    end
  end
end
