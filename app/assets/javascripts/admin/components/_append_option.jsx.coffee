window.CmdpAdmin.AppendOption = React.createClass
  onClick: (e) ->
    @props.onDelete(e.target.id)
    return
  render: ->
    optionNodes = []
    for x in @props.filters
      node = `<div key={x.value}>
                {x.platformName}: {x.valueName}
                <i id={x.value} className='del fa fa-times' onClick={this.onClick}></i>
              </div>`
      optionNodes.push(node)

    `<li className='filter-options'>
      {optionNodes}
    </li>`