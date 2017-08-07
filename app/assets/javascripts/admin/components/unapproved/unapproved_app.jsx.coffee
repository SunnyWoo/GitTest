# Public: Unapproved List Component
#
# Properties:
#   type     - Standard or express
#   filters  - Api filters, get standard or express
#   url      - Api url
#   countUrl - Count api url
#
# End

# @cjsx

@CPA.Unapproved.App = React.createClass
  propTypes:
    type: React.PropTypes.string
    filters: React.PropTypes.array
    url: React.PropTypes.string
    countUrl: React.PropTypes.string

  getInitialState: ->
    results: []
    pagination: {}
    totalEntries: []

  componentDidMount: ->
    @getResults(@props.filters)

  render: ->
    <div>
      <CPA.Unapproved.NavTabs active={@props.type} totalItems={@state.totalEntries}/>
      <CPA.Unapproved.List results={@state.results}
                           pagination={@state.pagination}
                           onChange={@changePage} />
    </div>

  changePage: (e) ->
    @getResults(@props.filters, e.page)

  getResults: (filters, page=1) ->
    listRequest = $.ajax
      url: @props.url
      type: 'GET'
      dataType: 'json'
      data:
        q:
          'shipping_info_shipping_way_in': filters[0].value
        page: page

    counterRequest = $.ajax
      url: @props.countUrl
      type: 'GET'
      dataType: 'json'

    listRequest.done (response) =>
      @setState
        results:    response.orders
        pagination: response.meta.pagination

    counterRequest.done (response) =>
      @setState
        totalEntries: response