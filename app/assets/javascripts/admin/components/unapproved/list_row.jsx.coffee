#@cjsx

@CPA.Unapproved.ListRow = React.createClass
  render: ->

    tagsHtml = @props.order.tags.map (x) -> <label className='label label-success'>{x}</label>

    <tr style={ { backgroundColor: 'lightblue' } if @props.order.coupon_code == 'MUGSH0000' }>
      <td>{@props.order.id}</td>
      <td>{@renderOrderItem()}</td>
      <td>
        <table className="table table-striped table-bordered">
          <tr>
            <td>OrderNoumber</td>
            <td><a href={@props.order.links.show}>{@props.order.order_no}</a> {tagsHtml}</td>
          </tr>
          <tr>
            <td>RemoteOrderNo</td>
            <td>{@props.order.remote_order_no}</td>
          </tr>
          <tr>
            <td>CouponCode</td>
            <td>{@props.order.coupon_code}</td>
          </tr>
          <tr>
            <td>OrderPrice</td>
            <td>{@props.order.order_price.price_in_currency}</td>
          </tr>
          <tr>
            <td>CreatedAt</td>
            <td>{new Date(@props.order.created_at).toLocaleString()}</td>
          </tr>
          <tr>
            <td>Created Source</td>
            <td><div title={@props.order.user_agent}>{@props.order.platform}</div></td>
          </tr>
          <tr>
            <td>Message</td>
            <td><div title={@props.order.message}>{@props.order.message}</div></td>
          </tr>
        </table>
      </td>
      <td>
        <CPA.Unapproved.Note orderID={'note_'+@props.order.id}
                             createUrl={@props.order.links.create_note}
                             notes={@props.order.notes}/>
      </td>
      <td>
        <ul className="order-info">
          <li>Name: <span className="info">{@props.order.billing_info.name}</span></li>
          <li>Email: <span className="info">{@props.order.billing_info.email}</span></li>
          <li>Address: <span className="info">{@props.order.billing_info.address}</span></li>
          <li>City: <span className="info">{@props.order.billing_info.city}</span></li>
          <li>State: <span className="info">{@props.order.billing_info.state}</span></li>
          <li>Zip code: <span className="info">{@props.order.billing_info.zip_code}</span></li>
          <li>Country: <span className="info">{@props.order.billing_info.country}</span></li>
          <li>Mobile: <span className="info">{@props.order.billing_info.phone}</span></li>
        </ul>
      </td>
      <td>
        <ul className="order-info">
          <li>Name: <span className="info">{@props.order.shipping_info.name}</span></li>
          <li>Email: <span className="info">{@props.order.shipping_info.email}</span></li>
          <li>Address: <span className="info">{@props.order.shipping_info.address}</span></li>
          <li>City: <span className="info">{@props.order.shipping_info.city}</span></li>
          <li>State: <span className="info">{@props.order.shipping_info.state}</span></li>
          <li>Zip code: <span className="info">{@props.order.shipping_info.zip_code}</span></li>
          <li>Country: <span className="info">{@props.order.shipping_info.country}</span></li>
          <li>Mobile: <span className="info">{@props.order.shipping_info.phone}</span></li>
        </ul>
      </td>
      <td>
        <a href={@props.order.links.approve} className="btn" data-confirm="Please confirm again, the picture! Determined by the order?" data-method="patch" data-remote="true" rel="nofollow">Approved</a>
      </td>
    </tr>

  renderOrderItem: ->
    items = @props.order.order_items.map (item, i) ->
      <CPA.Unapproved.OrderItem item={item} key={i} itemID={item+"_"+i} />

