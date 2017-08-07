# @cjsx

@CPA.Base.SelectInput = React.createClass
  propTypes:
    value: React.PropTypes.string
    collection: React.PropTypes.array
    onChange: React.PropTypes.func.isRequired

  render: ->
    options = @props.collection.map (item, i) ->
      <option key={i} value={item.value}>{item.label}</option>

    <select className="cpa-select-input"
            value={@props.value}
            onChange={@props.onChange}>
      {options}
    </select>
