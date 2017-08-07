# @cjsx

@CPA.Base.TextInput = React.createClass
  getInitialState: ->
    value: @props.value

  updateValue: (e) ->
    @setState(value: e.target.value)
    @props.onChange?(value: e.target.value)

  completeValue: (e) ->
    @props.onBlur?(value: e.target.value)

  fireSubmit: (e) ->
    @props.onKeyUp?(keyCode: e.keyCode)

  render: ->
    <input className={@props.className}
           placeholder={@props.placeholder}
           type="text"
           value={@state.value}
           onChange={@updateValue}
           onKeyUp={@fireSubmit}
           onBlur={@completeValue} />