# @cjsx

@CmdpAdmin.ReportSearchResult = React.createClass
  propTypes:
    filters: React.PropTypes.array
    url: React.PropTypes.string

  getInitialState: ->
    results: []
    platformType: ''

  componentDidMount: ->
    @getReports(@props.filters)

  componentWillReceiveProps: (nextProps) ->
    @getReports(nextProps.filters)

  render: ->
    sumOf = (data ,key) -> _.reduce(_.pluck(data, key), (a, b) -> a + b)

    results = @state.results.map (item, i) =>
      <tr key={i}>
        <td>{item.date}</td>
        <td>{@state.platformType}</td>
        <td className="text-right">{item.total_orders}</td>
        <td className="text-right">{item.items_amount}</td>
        <td className="text-right">{item.users_amount}</td>
        <td className="text-right">{@_formatCurrency item.subtotal}</td>
        <td className="text-right">{@_formatCurrency item.discount}</td>
        <td className="text-right">{@_formatCurrency item.shipping_fee}</td>
        <td className="text-right">{@_formatCurrency item.shipping_fee_discount}</td>
        <td className="text-right">{@_formatCurrency item.price}</td>
        <td className="text-right red">({@_formatCurrency item.total_refund})</td>
        <td className="text-right">{@_formatCurrency item.total}</td>
        <td className="text-right">{@_formatCurrency item.avg_order_price}</td>
        <td className="text-right">{@_formatCurrency item.avg_per_user_price}</td>
      </tr>

    <table className="report-search-result table table-striped table-bordered table-hover">
      <thead>
        <tr>
          <th>Date</th>
          <th>Platform</th>
          <th>Total Orders</th>
          <th>Item Amount</th>
          <th>Purchased User Amount</th>
          <th>Subtotal</th>
          <th>Discount</th>
          <th>Shipping Fee</th>
          <th>Shipping Fee Discount</th>
          <th>Price</th>
          <th>Refund</th>
          <th>Total</th>
          <th>Average Order Amount</th>
          <th>Average User Amount</th>
        </tr>
      </thead>
      <tbody>
        {results}
        <tr className="total-summary">
          <td colSpan="2" className="title">Total:</td>
          <td className="text-right">{sumOf(@state.results, 'total_orders')}</td>
          <td className="text-right">{sumOf(@state.results, 'items_amount')}</td>
          <td className="text-right">{sumOf(@state.results, 'users_amount')}</td>
          <td className="text-right">{@_formatCurrency sumOf(@state.results, 'subtotal')}</td>
          <td className="text-right">{@_formatCurrency sumOf(@state.results, 'discount')}</td>
          <td className="text-right">{@_formatCurrency sumOf(@state.results, 'shipping_fee')}</td>
          <td className="text-right">{@_formatCurrency sumOf(@state.results, 'shipping_fee_discount')}</td>
          <td className="text-right">{@_formatCurrency sumOf(@state.results, 'price')}</td>
          <td className="text-right red">({@_formatCurrency sumOf(@state.results, 'total_refund')})</td>
          <td className="text-right">{@_formatCurrency sumOf(@state.results, 'total')}</td>
          <td></td>
          <td></td>
        </tr>
      </tbody>
    </table>

  getReports: (filters) ->
    url = @props.url

    filterData =
      startAt: ''
      endAt: ''
      platform: ''
      country: ''

    for filter in filters
      filterData[filter.type] = filter.value

    if filterData['platform'] is ''
      @setState(platformType: 'All')
    else
      @setState(platformType: filterData['platform'])

    ajax = $.ajax
      url: url
      type: 'GET'
      dataType: 'json'
      data:
        q:
          date_gteq: filterData.startAt
          date_lteq: filterData.endAt
          platform_cont: filterData.platform
          country_code_cont: filterData.country

    ajax.done (response) =>
      @setState(results: response.reports)

  _formatCurrency: (value = 0) ->
    regex = /(\d+)(\d{3})/
    value = value.toString()
    while regex.test(value)
      value = value.replace(regex, '$1' + ',' + '$2')
    "$#{value}"
