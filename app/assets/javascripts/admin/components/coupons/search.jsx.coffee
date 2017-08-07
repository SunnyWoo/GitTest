# Public: Coupon Search Filter Component
#
# Properties:
#   filters - An array, include type and value
#
# End

#= require plugins/lodash.min
#= require react-mini-router

# @cjsx

@CPA.Coupons.Search = React.createClass
  propTypes:
    filters: React.PropTypes.array

  getInitialState: ->
    filters = for filter, index in @props.filters
      _.extend(filter, id: index + 1)
    nextId: filters.length + 1
    filters: filters

  addFilter: ->
    newFilters = @state.filters.concat([{id: @state.nextId}])
    @setState(filters: newFilters, nextId: @state.nextId + 1)

  updateFilter: (self, id) -> (e) ->
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
  
  updateSearchText: (e) ->
    newFilters = @state.filters
    newFilters[0].value = e.value
    @setState(filters: newFilters)

  autoSubmit: (e) ->
    if e.keyCode is 13
      @submit()
  
  submit: ->
    ReactMiniRouter.navigate('/?q=' + @getFiltersQueryString() + '&page=' + 1)

  getFiltersQueryString: ->
    filters = for filter in @state.filters
      { type: filter.type, value: filter.value }
    JSON.stringify(filters)

  render: ->
    filterInputs = @state.filters.map (item) =>
      if item.type isnt 'search'
        <CPA.Coupons.FilterInput key={item.id}
                                 filterID={item.id}
                                 type={item.type} 
                                 value={item.value} 
                                 onChange={@updateFilter(@, item.id)}
                                 onDelete={@onDeleteFilter}/>

    <div className='coupon-filters'>
      <div>
        <CPA.Base.DefaultFilter name="Coupon Code" />
        {filterInputs}
        <button className="btn btn-md report-add-filter" onClick={@addFilter}>
          <i className="fa fa-plus" />
        </button>
      </div>
      <div className="coupon-search clearfix">
        <CPA.Base.TextInput className="form-control pull-left"
                            value={@state.filters[0].value}
                            placeholder={I18n.t('js.coupon.index.search_desc')}
                            onChange={@updateSearchText}
                            onKeyUp={@autoSubmit} />
        <button type="submit" className="btn btn-md pull-left" onClick={@submit}>
          <i className="fa fa-search" /> {I18n.t('js.button.search')}
        </button>
      </div>
    </div>
