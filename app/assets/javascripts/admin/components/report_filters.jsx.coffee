#= require plugins/lodash.min
#= require react-mini-router

# @cjsx

@CmdpAdmin.ReportFilters = React.createClass
  propTypes:
    filters: React.PropTypes.array

  getInitialState: ->
    filters = for filter, index in @props.filters
      _.extend(filter, id: index + 1)
    nextId: filters.length + 1
    filters: filters
    results: @props.results

  addFilter: ->
    newFilters = @state.filters.concat([{id: @state.nextId}])
    @setState(filters: newFilters, nextId: @state.nextId + 1)

  onFilterChange: (self, id) -> (e) ->
    newFilters = self.state.filters
    index = _.findIndex(newFilters, id: id)
    newFilters[index] = _.extend(newFilters[index], e.pair)
    self.setState(filters: newFilters)

  onDeleteFilter: (id) ->
    id = parseInt(id)
    newFilters = @state.filters
    _.remove newFilters, (filter) ->
      filter.id is id
    @setState(filters: newFilters)

  submit: ->
    ReactMiniRouter.navigate('/?q=' + @getFiltersQueryString())

  getFiltersQueryString: ->
    filters = for filter in @state.filters
      { type: filter.type, value: filter.value }
    JSON.stringify(filters)

  render: ->
    filterInputs = @state.filters.map (item) =>
      <CmdpAdmin.FilterInput key={item.id}
                             filterID={item.id}
                             type={item.type} 
                             value={item.value} 
                             onChange={@onFilterChange(@, item.id)}
                             onDelete={@onDeleteFilter}/>

    <div className='report-filters'>
      {filterInputs}

      <button className="btn btn-lg report-add-filter" onClick={@addFilter}>
        <i className="fa fa-plus" />
      </button>

      <button className="btn btn-lg" onClick={@submit}>
        <i className="fa fa-search" /> Submit
      </button>
    </div>
