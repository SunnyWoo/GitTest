# @cjsx
@CPA.PriceTiers.Tier = React.createClass
  updatePrice: (currency) -> (e) =>
    priceTier = @props.priceTier.set(currency, e.value)
    @props.onChange?(value: priceTier)

  updateDescription: (e) ->
    priceTier = @props.priceTier.set('description', e.target.value)
    @props.onChange?(value: priceTier)

  render: ->
    tds = for currency in @props.currencies
            if @props.editing
              <td><CPA.Base.NumberInput value={@props.priceTier.get(currency)} className="form-control" onChange={@updatePrice(currency)} /></td>
            else
              <td>{@props.priceTier.get(currency)}</td>
    description = if @props.editing
                    <td><input className='form-control' type='text' value={@props.priceTier.get('description')} onChange={@updateDescription} /></td>
                  else
                    <td>{@props.priceTier.get('description')}</td>
    <tr>
      <td>{@props.priceTier.get('id')}</td>
      <td>Tier {@props.priceTier.get('tier')}</td>
      {tds}
      {description}
    </tr>
