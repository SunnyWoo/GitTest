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

@CPA.Coupons.FilterInput = React.createClass
  propTypes:
    type: React.PropTypes.string
    value: React.PropTypes.string
    filterID: React.PropTypes.number
    onChange: React.PropTypes.func.isRequired
    onDelete: React.PropTypes.func.isRequired

  getInitialState: ->
    filtersCollection: [
      {value: '',           label: 'Select type...'}
      {value: 'couponType', label: 'Coupon Type'}
      {value: 'timeUsed',   label: 'Time Used'}
      {value: 'starts',     label: 'Starts'}
      {value: 'status',     label: 'Status'}
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

  setUsedValue: (e) ->
    @setState(value: e.value)
    pair = { type: @state.type, value: e.value }
    @props.onChange(pair: pair)

  deleteFilter: (e) ->
    @props.onDelete(@props.filterID)

  valueInput: ->
    @["#{@state.type}Input"]?()

  couponTypeInput: ->
    couponTypeCollection = [
      {value: '',           label: 'Select Coupon Type...'}
      {value: 'fixed',      label: '$'}
      {value: 'percentage', label: '%'}
    ]
    <CPA.Base.SelectInput value={@state.value}
                          onChange={@setValue}
                          collection={couponTypeCollection} />

  timeUsedInput: ->
    timeUsedCollection = [
      {value: '',                   label: 'Select Coupon Type...'}
      {value: 'usage_count_eq',     label: 'equal to'}
      {value: 'usage_count_not_eq', label: 'not equal to'}
      {value: 'usage_count_lt',     label: 'less than'}
      {value: 'usage_count_gt',     label: 'greater than'}
    ]

    <CPA.Coupons.UsedFilter value={@state.value}
                            collection={timeUsedCollection}
                            onChange={@setUsedValue} />

  startsInput: ->
    <CPA.Base.DateInput value={@state.value} onChange={@setValue} />

  statusInput: ->
    statusCollection = [
      {value: '',   label: 'Select Status...'}
      {value: '1',  label: 'Enable'}
      {value: '0',  label: 'Disable'}
    ]
    <CPA.Base.SelectInput value={@state.value}
                          onChange={@setValue}
                          collection={statusCollection} />
  render: ->
    # value should fetch from hashbang url
    <div className="cpa-filter-input">
      <CPA.Base.SelectInput value={@state.type}
                            onChange={@setType}
                            collection={@state.filtersCollection} />
      {@valueInput()}
      <i className="del fa fa-times" onClick={@deleteFilter}></i>
    </div>
