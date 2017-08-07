# @cjsx
@CPA.Coupons.ChildrenList = React.createClass
  propTypes:
    items: React.PropTypes.array

  checkUsage: (count) ->
    if count is 0
      status = I18n.t('js.coupon.index.unused')
    else
      status = I18n.t('js.coupon.index.used')

  render: ->
    results = @props.items.map (item, i) =>
      <tr key={i}>
        <td>{item.code}</td>
        <td>{@checkUsage(item.usage_count)}</td>
        <td>
          <div>{I18n.t('js.coupon.new.begin')}: {item.begin_at}</div>
          <div>{I18n.t('js.coupon.new.expires')}: {item.expired_at}</div>
        </td>
      </tr>

    <div>
      <table className="coupon-children-list table table-striped table-bordered table-hover">
        <thead>
          <tr>
            <th>{I18n.t('js.coupon.index.code')}</th>
            <th>{I18n.t('js.coupon.index.status')}</th>
            <th>{I18n.t('js.coupon.index.start_end')}</th>
          </tr>
        </thead>
        <tbody>
          {results}
        </tbody>
      </table>
    </div>
