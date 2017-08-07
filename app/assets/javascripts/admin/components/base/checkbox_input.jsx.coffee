# @cjsx

@CPA.Base.CheckboxInput = React.createClass
  propTypes:
    name: React.PropTypes.string
    value: React.PropTypes.boolean
    text: React.PropTypes.string
    disabled: React.PropTypes.boolean

  getInitialState: ->
    checked: @props.value

  render: ->
    <div className="checkbox" key={@props.value}>
      <label>
        <input className="ace"
               type="checkbox"
               name={@props.name}
               value={@props.value}
               checked={@state.checked}
               onChange={@selectItem}
               disabled={@props.disabled} />
        <span className="lbl"> {@props.text}</span>
      </label>
    </div>

  selectItem: (e) ->
    checked = !@state.checked
    @setState(checked: checked)
    @props.onChange?(value: checked)
