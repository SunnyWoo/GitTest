# Public: Report App Component
#
# filters - An array, include type and value
# search_url - Report API url
# update_url - Manually update report data API url
#
# End

#= require react-mini-router

# @cjsx

@CmdpAdmin.ReportApp = React.createClass
  mixins: [
    ReactMiniRouter.RouterMixin
  ]

  routes:
    '/': 'search'

  render: -> @renderCurrentRoute()

  search: (qs) ->
    filters = if qs.q
                JSON.parse(qs.q)
              else
                date = new Date()
                date.setDate(date.getDate() - 7)
                date = @dateToString(date)
                [{ type: 'startAt', value: date }]

    <div className="report-app">
      <CmdpAdmin.ReportFilters filters={filters} />
      <CmdpAdmin.ReportUpdate url={@props.update_url}/>
      <CmdpAdmin.GetCSVFile filters={filters} url={@props.search_url}/>
      <CmdpAdmin.ReportSearchResult filters={filters} url={@props.search_url} />
    </div>

  dateToString: (date) ->
    year  = date.getFullYear()
    month = date.getMonth() + 1
    day   = date.getDate()
    month = "0#{month}" if month < 10
    day   = "0#{day}"   if day < 10
    "#{year}-#{month}-#{day}"

