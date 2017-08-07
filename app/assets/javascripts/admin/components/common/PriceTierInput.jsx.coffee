# @cjsx

@CPA.Common.PriceTierInput = React.createClass
  mixins: [CPA.FluxMixin, Fluxxor.StoreWatchMixin('PriceTierStore')]

  getInitialState: ->
    priceTiers: []

  componentDidMount: ->
    @getFlux().actions.loadPriceTiersFromServer()

  getStateFromFlux: ->
    priceTiers: @getFlux().store('PriceTierStore').getAll()

  updateValue: (e) ->
    @props.onChange?(value: e.target.value)

  render: ->
    <select className='form-control' value={@props.value or ''} onChange={@updateValue} disabled={@props.disabled}>
      <option />
      {@renderOptions()}
    </select>

  renderOptions: ->
    for priceTier in @state.priceTiers
      label = "Tier #{priceTier.tier} / TWD #{priceTier.TWD}"
      <option key={priceTier.id} value={priceTier.id}>{label}</option>
