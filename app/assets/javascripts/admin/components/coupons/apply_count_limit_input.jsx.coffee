# @cjsx
@CPA.Coupons.ApplyCountLimitInput = React.createClass
  propTypes:
    value: React.PropTypes.number
    onChange: React.PropTypes.func

  getInitialState: ->
    value: @props.value
    noLimit: (@props.value is -1)

  updateValue: (e) ->
    @setState(value: e.target.value)
    @props.onChange?(value: e.target.value)

  updateLimit: (e) ->
    @setState(noLimit: e.target.checked)
    if e.target.checked
      @props.onChange?(value: -1)
    else
      @props.onChange?(value: @state.value)

  render: ->
    <div className="row">
      <div className="col-sm-2">
        {@renderInput()}
      </div>
      <div className="col-sm-2">
        <label><input type="checkbox" checked={@state.noLimit} onChange={@updateLimit} />{I18n.t('js.coupon.new.no_limit')}</label>
      </div>
    </div>

  renderInput: ->
    if @state.noLimit
      <input type="text" className="form-control" value="∞" disabled />
    else
      <input type="text" className="form-control" value={@state.value} onChange={@updateValue} />
