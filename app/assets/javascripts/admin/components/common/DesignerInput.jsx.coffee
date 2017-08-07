# @cjsx

@CPA.Common.DesignerInput = React.createClass
  mixins: [CPA.FluxMixin, Fluxxor.StoreWatchMixin('DesignerStore')]

  getInitialState: ->
    designers: []

  componentDidMount: ->
    @getFlux().actions.loadDesignersFromServer()

  getStateFromFlux: ->
    designers: @getFlux().store('DesignerStore').getAll()

  updateValue: (e) ->
    @props.onChange?(value: e.target.value)

  render: ->
    <select className='form-control' value={@props.value or ''} onChange={@updateValue} disabled={@props.disabled}>
      <option />
      {@renderOptions()}
    </select>

  renderOptions: ->
    for designer in @state.designers
      <option key={designer.id} value={designer.id}>{designer.displayName}</option>
