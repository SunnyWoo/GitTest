class PriceTierUpdaterService
  attr_reader :changeset

  def initialize(changeset)
    @changeset = changeset || {}
  end

  def save
    changeset.values.each do |change|
      case change['method']
      when 'create' then create(change)
      when 'update' then update(change)
      end
    end
    retier
  end

  def create(change)
    cid = change['tier'].delete('cid')
    data = change['tier']
    tiers_with_cid[cid] = PriceTier.create(data: data)
  end

  def update(change)
    cid = change['tier'].delete('cid')
    id = change['tier'].delete('id')
    tier = if id
             PriceTier.find(id)
           else
             tiers_with_cid[cid]
           end
    tier.update(data: change['tier'])
  end

  def tiers_with_cid
    @tiers_with_cid ||= {}
  end

  def retier
    PriceTier.order_by_twd_price.each_with_index do |tier, index|
      tier.update tier: index + 1
    end
  end
end
