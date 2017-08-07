# Public: Coupon Used Filter Component
#
# Properties:
#   value      - the used selector input's value
#   collection - an array, include filter value and label
# 
# Event Functions:
#   onChange - the filter on change event
#
# End

# @cjsx

@CPA.Coupons.UsedFilter = React.createClass
  getInitialState: ->
    value: @props.value
    collection: @props.collection
    usedType: 'usage_count_eq'
    usedValue: 1

  setUsedTypeValue: (e) ->
    used = e.target.value + ',' + @state.usedValue
    @setState(usedType: e.target.value)
    @props.onChange?(value: used)
  
  setUsedValue: (e) ->
    used = @state.usedType + ',' + e.target.value
    @setState(usedValue: e.target.value)
    @props.onChange?(value: used)

  render: ->
    number = if @props.value.split(',')[1] then @props.value.split(',')[1] else @state.usedValue
    <div className="select-group">
      <CPA.Base.SelectInput value={@props.value.split(',')[0]}
                            onChange={@setUsedTypeValue}
                            collection={@state.collection} />
      <input className="used-value"
             type="number" value={number}
             onChange={@setUsedValue} />
    </div>