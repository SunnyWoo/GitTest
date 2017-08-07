# @cjsx
@CPA.Coupons.QuantityInput = React.createClass
  propTypes:
    value: React.PropTypes.number
    onChange: React.PropTypes.func

  getInitialState: ->
    type: if @props.value > 1 then 'greaterThan' else 'equalTo'
    value: @props.value

  updateType: (e) ->
    @setState(type: e.target.value)
    if e.target.value is 'equalTo'
      @updateValue(value: 1)

  updateValue: (e) ->
    @setState(value: e.value)
    @props.onChange?(value: e.value)

  render: ->
    <div className="row">
      <div className="col-sm-2">
        <select value={@state.type} onChange={@updateType} className="form-control">
          <option value="equalTo">{I18n.t('js.coupon.new.equal_to')}</option>
          <option value="greaterThan">{I18n.t('js.coupon.new.greater_than')}</option>
        </select>
      </div>
      <div className="col-sm-2">
        {@renderFixedNumberOrInput()}
      </div>
    </div>

  renderFixedNumberOrInput: ->
    switch @state.type
      when 'equalTo'
        '1'
      when 'greaterThan'
        <CPA.Base.NumberInput className="form-control" value={@state.value}
                              onChange={@updateValue} />
