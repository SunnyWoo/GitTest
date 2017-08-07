window.CmdpAdmin.PlatformValue = React.createClass
  render: ->
    keys = @props.valueKey
    optionNodes = @props.valueName.map (name, i) ->
      nameKey = keys[i]
      `<option key={i} value={nameKey}>{name}</option>`

    `<select className='value' onChange={this.props.onValueChange}>
      {optionNodes}
    </select>`