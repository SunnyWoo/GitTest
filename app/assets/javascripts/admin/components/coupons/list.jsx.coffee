# Public: Coupon Filter Input Component
#
# Properties:
#   filters - An array, include type and value
#   url     - Coupon API url
#
# End

# @cjsx

@CPA.Coupons.List = React.createClass
  propTypes:
    filters: React.PropTypes.array
    url: React.PropTypes.string

  getInitialState: ->
    show: false
    results: []
    pagination: []

  componentDidMount: ->
    @getReports(@props.filters)

  componentWillReceiveProps: (nextProps) ->
    @getReports(nextProps.filters)

  render: ->
    results = @state.results.map (item, i) =>
      <CPA.Coupons.CouponRow coupon={item} />

    <div>
      <table className="report-search-result table table-striped table-bordered table-hover">
        <thead>
          <tr>
            <th>{I18n.t('js.coupon.index.detail')}</th>
            <th>{I18n.t('js.coupon.index.used')}</th>
            <th>{I18n.t('js.coupon.index.start_end')}</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {results}
        </tbody>
      </table>
      <div id="list_pagination">
        <CPA.Base.Pagination page={@state.pagination} onClick={@changePage} />
      </div>
    </div>

  changePage: (e) ->
    @getReports(@props.filters, e.page)

  queryData: (filterData) ->
    data =
      discount_type_eq:   filterData.couponType
      begin_at_gteq:      filterData.starts
      is_enabled_eq:      filterData.status
      title_or_code_or_children_code_cont: filterData.search
      usage_count_eq:     filterData.usage_count_eq
      usage_count_not_eq: filterData.usage_count_not_eq
      usage_count_lteq:     filterData.usage_count_lt
      usage_count_gteq:     filterData.usage_count_gt
    _.omit(data, _.isEmpty)

  getReports: (filters, page=1) ->
    url = @props.url

    filterData =
      couponType:         ''
      usage_count_eq:     ''
      usage_count_not_eq: ''
      usage_count_lt:     ''
      usage_count_gt:     ''
      starts:             ''
      status:             ''
      search:             ''

    for filter in filters
      if filter.type is 'timeUsed'
        usedType = filter.value.split(',')[0]
        filterData[usedType] = filter.value.split(',')[1]
      else
        filterData[filter.type] = filter.value

    ajax = $.ajax
      url: url
      type: 'GET'
      dataType: 'json'
      data:
        q: @queryData(filterData)
        page: page

    ajax.done (response) =>
      @setState
        results:    humps.camelizeKeys(response).coupons
        pagination: response.meta.pagination
