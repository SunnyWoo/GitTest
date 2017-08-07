# @cjsx
@CPA.Base.BdeventInput = React.createClass
  getInitialState: ->
    value: @props.value

  updateValue: (e) ->
    @setState(value: e.target.value)
    @props.onChange?(value: e.target.value)

  componentDidMount: ->
    $.getJSON('/admin/bdevents').success (data) =>
      @setState(bdevents: data.bdevents)

  componentWillUnmount: ->
    @setState(value: [])
    @props.onChange?(value: [])

  render: ->
    <select value={@state.value} onChange={@updateValue} disabled={@props.disabled} >
      <option>--</option>
      {@renderOptions()}
    </select>

  renderOptions: ->
    return unless @state.bdevents
    for bdevent in @state.bdevents
      startsAt = new Date(humps.camelizeKeys(bdevent).startsAt).toLocaleString()
      endsAt = new Date(humps.camelizeKeys(bdevent).endsAt).toLocaleString()
      label = "#{bdevent.title} (#{startsAt} ~ #{endsAt})"
      <option key={bdevent.id} value={bdevent.id}>{label}</option>
