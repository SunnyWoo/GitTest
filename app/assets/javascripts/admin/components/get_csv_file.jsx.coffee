# @cjsx

@CmdpAdmin.GetCSVFile = React.createClass
  propTypes:
    filters: React.PropTypes.array
    url: React.PropTypes.string

  getURL: ->
    @props.url + '.csv?' + @getFiltersQueryString()

  render: ->
    <div className="report-update">
      <a href={@getURL()} className="btn btn-md btn-info">
        Export
      </a>
    </div>

  getFiltersQueryString: ->
    filters = {}
    for filter in @props.filters
      filters[filter.type] = filter.value

    filters =
      date_gteq: filters.startAt
      date_lteq: filters.endAt
      platform_cont: filters.platform
      country_code_cont: filters.country

    for key, value of filters
      delete filters[key] unless value

    $.param(q: filters)
