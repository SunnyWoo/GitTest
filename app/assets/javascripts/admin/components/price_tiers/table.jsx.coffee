# @cjsx
@CPA.PriceTiers.Table = React.createClass
  updateTier: (e) ->
    @props.priceTiers.update(e.value)
    @props.onChange?(value: @props.priceTiers)

  render: ->
    currencies = for currency in @props.currencies
                   <th>{currency}</th>

    tiers = @props.priceTiers.tiers.map (priceTier) =>
      <CPA.PriceTiers.Tier key={priceTier.get('id') or priceTier.get('cid')}
                           priceTier={priceTier}
                           currencies={@props.currencies}
                           editing={@props.editing}
                           onChange={@updateTier} />
    <table className="table">
      <thead>
        <th>ID</th>
        <th>Tier</th>
        {currencies}
        <th>Description</th>
      </thead>
      <tbody>{tiers.toArray()}</tbody>
    </table>
