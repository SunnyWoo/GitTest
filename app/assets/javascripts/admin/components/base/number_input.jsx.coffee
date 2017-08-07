# @cjsx
@CPA.Base.NumberInput = React.createClass
  getInitialState: ->
    value: @props.value

  updateValue: (e) ->
    @setState(value: e.target.value)

  validateValue: (e) ->
    value = parseFloat(e.target.value)
    @setState(value: value)
    @props.onChange?(value: value)

  render: ->
    <input className={@props.className}
           type="number"
           value={@state.value}
           onChange={@updateValue}
           onBlur={@validateValue}
           disabled={@props.disabled} />
