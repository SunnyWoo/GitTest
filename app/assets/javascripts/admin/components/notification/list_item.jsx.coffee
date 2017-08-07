# @cjsx

@CPA.Notification.ListItem = React.createClass

  render: ->
    <tr key={@props.item.id}>
      <td>{@props.item.id}</td>
      <td>{new Date(@props.item.delivery_at).toLocaleString()}</td>
      <td>{@props.item.status}</td>
      <td>{@props.item.message}</td>
      <td>{@props.item.notification_trackings_count}</td>
      <td>
        <button className="btn btn-sm btn-primary" onClick={@showItem}>Detail</button>
        {@renderDeleteBtn()}
        {@renderReprotBtn()}
      </td>
    </tr>

  renderDeleteBtn: ->
    if not @props.is_sent
      <button className="btn btn-sm btn-danger" onClick={@deleteItem}>Delete</button>

  renderReprotBtn: ->
    if not @props.is_sent
      <button className="btn btn-sm btn-info" onClick={@reportItem}>Report</button>

  showItem: (e) ->
    @props.showItem?(@props.item.id)

  deleteItem: (e) ->
    @props.deleteItem?(@props.item.id)

  reportItem: (e) ->
    @props.reportItem?(@props.item.id)
