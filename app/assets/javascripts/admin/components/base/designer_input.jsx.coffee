# @cjsx
@CPA.Base.DesignerInput = React.createClass
  updateValue: (e) ->
    @props.onChange?(value: e.target.value)

  componentDidMount: ->
    CPA.Actions.Designers.loadAll()
    CPA.Stores.Designers.on 'change', @updateDesigners

  componentWillUnmount: ->
    CPA.Stores.Designers.off 'change', @updateDesigners

  updateDesigners: ->
    @forceUpdate()

  render: ->
    <select value={@props.value or ''} onChange={@updateValue} disabled={@props.disabled}>
      <option />
      {@renderOptions()}
    </select>

  renderOptions: ->
    for designer in CPA.Stores.Designers.getAll()
      <option key={designer.id} value={designer.id}>{designer.displayName}</option>
