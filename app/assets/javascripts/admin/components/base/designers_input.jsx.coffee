# @cjsx
@CPA.Base.DesignersInput = React.createClass
  getInitialState: ->
    value: @props.value

  updateValue: (e) ->
    values = (option.value for option in e.target.options when option.selected)
    @setState(value: values)
    @props.onChange?(value: values)

  componentDidMount: ->
    $.getJSON('/admin/designers?page=all').success (data) =>
      @setState(designers: data.designers)
      $(React.findDOMNode(this.refs.designerSelect)).select2().on('change', (e) =>
        @updateValue(e)
      )

  componentWillUnmount: ->
    @setState(value: [])
    @props.onChange?(value: [])
    $(React.findDOMNode(this.refs.designerSelect)).select2('destroy')

  render: ->
    <select ref='designerSelect' multiple value={@state.value} disabled={@props.disabled}>
      {@renderOptions()}
    </select>

  renderOptions: ->
    return unless @state.designers
    for designer in @state.designers
      <option value={designer.id}>{designer.display_name}</option>
