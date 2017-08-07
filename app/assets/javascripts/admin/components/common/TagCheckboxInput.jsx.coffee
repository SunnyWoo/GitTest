# @cjsx

@CPA.Common.TagCheckboxInput = React.createClass
  propTypes:
    name: React.PropTypes.string
    value: React.PropTypes.number
    text: React.PropTypes.string
    tagIds: React.PropTypes.array
    checked: React.PropTypes.boolean

  getInitialState: ->
    checked: @props.checked
    tagIds: @props.tagIds

  selectItem: (e) ->
    value = parseInt(e.target.value)
    if @state.checked is false
      @state.tagIds.push(value)
      @setState(checked: true)
    else
      index = @state.tagIds.indexOf(value)
      @state.tagIds.splice(index, 1)
      @setState(checked: false)
    @props.onChange?(e, @state.tagIds)

  render: ->
    <div className="col-xs-2 checkbox" key={@props.value}>
      <label>
        <input className="ace"
               type="checkbox"
               name={@props.name}
               value={@props.value}
               checked={@state.checked}
               onChange={@selectItem}/>
        <span className="lbl">{@props.text}</span>
      </label>
    </div>
