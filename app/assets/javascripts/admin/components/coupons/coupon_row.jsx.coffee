#@cjsx

@CPA.Coupons.CouponRow = React.createClass
  render: ->
    <tr>
      <td>
        <div>
          <a href={@props.coupon.links.edit.path}>{@props.coupon.title}</a> /
          <span>{@renderCouponName()}</span>
        </div>
        <div>
          {@props.coupon.renderOffPrice}
          <br />
          {@renderFreeShipping()}
        </div>
      </td>
      <td>
        <a href={@renderOrderLink()} target="_blank">{@props.coupon.usageCount}</a>
      </td>
      <td>
        <div>{I18n.t('js.coupon.new.begin')}: {@props.coupon.beginAt}</div>
        <div>{I18n.t('js.coupon.new.expires')}: {@props.coupon.expiredAt}</div>
      </td>
      <td>
        <a className="btn btn-sm btn-primary" href={@props.coupon.links.edit.path}>{I18n.t('js.button.edit')}</a>
        <a className="btn btn-sm btn-primary" href={@props.coupon.links.usedOrders.path}>{I18n.t('js.button.export_used_orders')}</a>
      </td>
    </tr>

  renderCouponName: ->
    if @props.coupon.renderCoupon is 'Batch Generate'
      result = if @props.coupon.quantity == @props.coupon.childrenCount
                 <span>
                   <a href={@renderChildrenLink()}>show</a>
                   <a href={@renderExportLink()}> export</a>
                 </span>
               else
                 <span>
                   產生中
                   [{@props.coupon.childrenCount} / {@props.coupon.quantity}]
                 </span>
      <span>
        Batch Generate ({result})
      </span>
    else
      @props.coupon.renderCoupon

  renderOrderLink: ->
    couponTitle = encodeURIComponent @props.coupon.title
    link = '/admin/orders?coupon=' + couponTitle

  renderChildrenLink: ->
    link = '/admin/coupons/' + @props.coupon.id + '/children'

  renderExportLink: ->
    link = '/admin/coupons/' + @props.coupon.id + '/children.csv'

  renderFreeShipping: ->
    if @props.coupon.isFreeShipping == true
      "FreeShipping"
