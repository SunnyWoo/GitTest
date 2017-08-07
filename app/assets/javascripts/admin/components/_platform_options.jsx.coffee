window.CmdpAdmin.PlatformOptions = React.createClass
  render: ->
    keys = @props.platformKey
    optionNodes = @props.platformName.map (name, i) ->
      val = keys[i]
      `<option key={i} value={val} >{name}</option>`

    `<select className='platform' onChange={this.props.onPlatformChange}>
      <option value='---'> --- </option>
      {optionNodes}
    </select>`