# @cjsx
@CPA.Coupons.codeLength = React.createClass
  propTypes:
    value: React.PropTypes.number
    min: React.PropTypes.number

  updateValue: (e) ->
    @props.onChange?(value: e.target.value)

  render: ->
    <div className="col-sm-12">
      <span>Length：{@props.value}</span>
      <input value={@props.value} type="range" min={@props.min} max="20" step="1" onChange={@updateValue} disabled={@props.disabled}/>
    </div>
