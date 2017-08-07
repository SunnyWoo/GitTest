# Public: Unapproved List Component
#
# Properties:
#   totalItems - Both standard and express count
#
# End

# @cjsx

@CPA.Unapproved.NavTabs = React.createClass

  render: ->
    <ul className="nav nav-tabs">
      <li className={@active('standard')}>
        <a href='./unapproved#!/standard'>
          <i className="fa fa-gavel"></i>
          <span> Standard </span>
          <span className="badge badge-important">{@props.totalItems.standard}</span>
        </a>
      </li>
      <li className={@active('express')}>
        <a href='./unapproved#!/express'>
          <i className="fa fa-gavel"></i>
          <span> Express </span>
          <span className="badge badge-important">{@props.totalItems.express}</span>
        </a>
      </li>
    </ul>

  active: (tabName) ->
    if @props.active is tabName
      classStyle = 'active'
    else
      className = ''