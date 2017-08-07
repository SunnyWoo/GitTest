# Public: Coupon Filter Input Component
#
# Properties:
#   type     - the first level select input's value, ex: timeUsed, starts...etc
#   value    - the second level select input's value
#   filterID - the filter's id
#
# Event Functions:
#   onChange - the filter on change event
#   onDelete - the filter delete event
#
# End

# @cjsx

@CPA.Assets.FilterInput = React.createClass
  propTypes:
    type: React.PropTypes.string
    value: React.PropTypes.string
    filterID: React.PropTypes.number
    onChange: React.PropTypes.func.isRequired
    onDelete: React.PropTypes.func.isRequired

  getInitialState: ->
    filtersCollection: [
      {value: '',       label: 'Select type...'}
      {value: 'status', label: 'Status'}
      {value: 'begins', label: 'Begins at'}
      {value: 'ends',   label: 'Ends at'}
    ]

    type: @props.type
    value: @props.value

  setType: (e) ->
    @setState(type: e.target.value, value: '')
    pair = { type: e.target.value, value: '' }
    @props.onChange(pair: pair)

  setValue: (e) ->
    @setState(value: e.target.value)
    pair = { type: @state.type, value: e.target.value }
    @props.onChange(pair: pair)

  deleteFilter: (e) ->
    @props.onDelete(@props.filterID)

  valueInput: ->
    @["#{@state.type}Input"]?()

  statusInput: ->
    statusCollection = [
      {value: '',           label: 'Select Status Type...'}
      {value: 'ready',      label: 'ready'}
      {value: 'onBoard', label: 'onBoard'}
      {value: 'offBoard', label: 'offBoard'}
      {value: 'unavailable', label: 'hidden'}
    ]
    <CPA.Base.SelectInput value={@state.value}
                          onChange={@setValue}
                          collection={statusCollection} />

  beginsInput: ->
    <CPA.Base.DateInput value={@state.value} onChange={@setValue} />

  endsInput: ->
    <CPA.Base.DateInput value={@state.value} onChange={@setValue} />

  render: ->
    # value should fetch from hashbang url
    <div className="cpa-filter-input">
      <CPA.Base.SelectInput value={@state.type}
                            onChange={@setType}
                            collection={@state.filtersCollection} />
      {@valueInput()}
      <i className="del fa fa-times" onClick={@deleteFilter}></i>
    </div>
