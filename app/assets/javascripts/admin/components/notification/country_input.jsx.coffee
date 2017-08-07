# @cjsx

@CPA.Notification.CountryInput = React.createClass
  propTypes:
    value: React.PropTypes.string
    text: React.PropTypes.string
    onChange: React.PropTypes.func.isRequired

  getInitialState: ->
    checked: @props.checked

  render: ->
    <div className="checkbox noti-country" key={@props.value}>
      <label>
        <input className="ace"
               type="checkbox"
               name={@props.text}
               value={@props.value}
               checked={@state.checked}
               disabled={@props.disabled}
               onChange={@selectItem}/>
        <span className="lbl">{@props.text}</span>
      </label>
    </div>

  selectItem: (e) ->
    if @state.checked is false
      @setState(checked: true)
      @props.onChange?(e, true)
    else
      @setState(checked: false)
      @props.onChange?(e, false)