# Public: Unapproved List Component
#
# Properties:
#   results    - An array, the results of unapproved
#
# End

# @cjsx

@CPA.Unapproved.List = React.createClass
  propTypes:
    results: React.PropTypes.array
    pagination: React.PropTypes.object

  render: ->
    results = @props.results.map (item, i) =>
      <CPA.Unapproved.ListRow order={item} key={item.id}/>

    <div>
      <table className="unapproved-results table table-bordered table-hover">
        <thead>
          <tr>
            <th>ID</th>
            <th>Compressed Image</th>
            <th>Order Info</th>
            <th>Memorandum</th>
            <th>Billing Info</th>
            <th>Shipping Info</th>
            <th>Operation</th></tr>
        </thead>
        <tbody>
          {results}
        </tbody>
      </table>
      <div id="list_pagination">
        <CPA.Base.Pagination page={@props.pagination} onClick={@changePage} />
      </div>
    </div>

  changePage: (e) ->
    @props.onChange?(e)
