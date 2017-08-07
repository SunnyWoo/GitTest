# @cjsx

@CPA.Base.RadioInput = React.createClass
  propTypes:
    name: React.PropTypes.string
    value: React.PropTypes.string
    text: React.PropTypes.string

  render: ->
    <div className="radio" key={@props.name}>
      <label>
        <input type="radio" name={@props.name} value={@props.value} className="ace" onClick={@selectItem}/>
        <span className="lbl">{@props.text}</span>
      </label>
    </div>

  selectItem: (e)->
    @props.onClick?(e)