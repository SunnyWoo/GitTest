# @cjsx

@CPA.Common.ProductModelInput = React.createClass
  mixins: [CPA.FluxMixin, Fluxxor.StoreWatchMixin('ProductModelStore')]

  getInitialState: ->
    productModels: []

  componentDidMount: ->
    @getFlux().actions.loadProductModelsFromServer()

  getStateFromFlux: ->
    productModels: @getFlux().store('ProductModelStore').getAll()

  updateValue: (e) ->
    @props.onChange?(value: e.target.value)

  render: ->
    <select className='form-control' value={@props.value or ''} onChange={@updateValue} disabled={@props.disabled}>
      <option />
      {@renderOptions()}
    </select>

  renderOptions: ->
    for productModel in @state.productModels
      <option key={productModel.id} value={productModel.id}>{productModel.name}</option>
