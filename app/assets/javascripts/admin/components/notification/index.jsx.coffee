# @cjsx

@CPA.Notification.Index = React.createClass

  getInitialState: ->
    results: []
    pagination: []

  componentDidMount: ->
    @getList()

  getList: (page=1)->
    $.ajax
      type: 'GET'
      url: '/admin/notifications'
      dataType: 'json'
      data:
        page: page
      success: (response) =>
        @setState
          results: response.notifications
          pagination: response.meta.pagination

  changePage: (e) ->
    @getList(e.page)

  deleteItem: (id) ->
    url = '/admin/notifications/' + id
    $.ajax
      type: 'DELETE'
      url: url
      dataType: 'json'
      success: (response) =>
        @getList()

  showItem: (id) ->
    url = CPA.path("/notifications/#{id}")
    location.replace(url)

  reportItem: (id) ->
    url = CPA.path("/notifications/#{id}/report")
    location.replace(url)

  render: ->
    results = @state.results.map (item, i) =>
      <CPA.Notification.ListItem item={item}
                                 deleteItem={@deleteItem}
                                 showItem={@showItem}
                                 reportItem={@reportItem} />

    <div>
      <div id="list_pagination_head">
        <CPA.Base.Pagination page={@state.pagination} onClick={@changePage} />
      </div>
      <table className='unapproved-results table table-striped table-bordered table-hover'>
        <thead>
          <tr>
            <th>ID</th>
            <th>Time</th>
            <th>Status</th>
            <th>Message</th>
            <th>Open Count</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {results}
        </tbody>
      </table>
      <div id="list_pagination_foot">
        <CPA.Base.Pagination page={@state.pagination} onClick={@changePage} />
      </div>
    </div>
