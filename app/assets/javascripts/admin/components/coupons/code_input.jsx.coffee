# @cjsx
@CPA.Coupons.CodeInput = React.createClass
  propTypes:
    value: React.PropTypes.string
    onChange: React.PropTypes.func

  getInitialState: ->
    value: @props.value

  generateCode: (type, length)->
    query = { "type": type, length: length }
    $.getJSON("/admin/coupons/code", query).success (data) =>
      @updateValue(target: { value: data.code })

  updateValue: (e) ->
    @setState(value: e.target.value)
    @props.onChange?(value: e.target.value)

  render: ->
    <input type="text" className="form-control"
           value={@state.value} onChange={@updateValue} disabled={@props.disabled}/>
