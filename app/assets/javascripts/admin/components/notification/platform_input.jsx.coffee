# @cjsx

@CPA.Notification.PlatformInput = React.createClass
  propTypes:
    value: React.PropTypes.string
    text: React.PropTypes.string
    onClick: React.PropTypes.func.isRequired

  render: ->
    <div className="radio" key={@props.text}>
      <label>
        <input type="radio"
               name="platform"
               value={@props.value}
               className="ace"
               checked={@props.checked}
               disabled={@props.disabled}
               onClick={@selectItem} />
        <span className="lbl">{@props.text}</span>
      </label>
    </div>

  selectItem: (e)->
    @props.onClick?(e)