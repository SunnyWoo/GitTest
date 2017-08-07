# @cjsx
@CPA.Base.ProductModelInput = React.createClass
  getInitialState: ->
    value: @props.value

  updateValue: (e) ->
    values = (option.value for option in e.target.options when option.selected)
    @setState(value: values)
    @props.onChange?(value: values)

  componentDidMount: ->
    $.getJSON('/admin/products').success (data) =>
      @setState(categories: data.categories)
      $(React.findDOMNode(this.refs.modelSelect)).select2().on('change', (e) =>
        @updateValue(e)
      )

  componentWillUnmount: ->
    @setState(value: [])
    @props.onChange?(value: [])
    $(React.findDOMNode(this.refs.modelSelect)).select2('destroy')

  render: ->
    <select ref='modelSelect' multiple value={@state.value} disabled={@props.disabled}>
      {@renderOptgroups()}
    </select>

  renderOptgroups: ->
    return unless @state.categories
    for category in @state.categories
      <optgroup key={category.id} label={category.name}>
        {@renderOptions(category.models)}
      </optgroup>

  renderOptions: (models) ->
    for model in models
      <option value={model.id}>{model.name}</option>
