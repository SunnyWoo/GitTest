# @cjsx
@CPA.Base.PercentageInput = React.createClass
  getInitialState: ->
    value: Math.round(@props.value * 100)

  updateValue: (e) ->
    @setState(value: e.target.value)

  validateValue: (e) ->
    value = parseFloat(e.target.value)
    @setState(value: value)
    @props.onChange?(value: value / 100)

  render: ->
    <span>
      <input className={@props.className}
             type="number" value={@state.value}
             onChange={@updateValue} onBlur={@validateValue}
             disabled={@props.disabled} />
      %
    </span>
