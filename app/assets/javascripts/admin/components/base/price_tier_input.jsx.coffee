# @cjsx
@CPA.Base.PriceTierInput = React.createClass
  getInitialState: ->
    value: @props.value

  updateValue: (e) ->
    @setState(value: e.target.value)
    @props.onChange?(value: e.target.value)

  componentDidMount: ->
    $.getJSON('/admin/price_tiers').success (data) =>
      @setState(
        priceTiers: data.price_tiers,
        currencyCode: data.meta.current_currency_code
      )

  render: ->
    <select value={@state.value} onChange={@updateValue} disabled={@props.disabled} >
      <option />
      {@renderOptions()}
    </select>

  renderOptions: ->
    return unless @state.priceTiers
    for priceTier in @state.priceTiers
      label = "Tier #{priceTier.tier} / TWD #{priceTier.TWD}"
      if @state.currencyCode isnt 'TWD'
        label += " ≈ #{@state.currencyCode} #{priceTier[@state.currencyCode]}"
      <option key={priceTier.id} value={priceTier.id}>{label}</option>
