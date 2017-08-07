# @cjsx

@CPA.Base.ProductCategoryInput = React.createClass
  getInitialState: ->
    productCategories: []
    value: @props.value

  componentDidMount: ->
    $.getJSON('/admin/product_categories').success (data) =>
      @setState(productCategories: humps.camelizeKeys(data).productCategories)
      $(React.findDOMNode(this.refs.categorySelect)).select2().on('change', (e) =>
        @updateValue(e)
      )
  componentWillUnmount: ->
    @setState(value: [])
    @props.onChange?(value: [])
    $(React.findDOMNode(this.refs.categorySelect)).select2('destroy')

  updateValue: (e) ->
    values = (option.value for option in e.target.options when option.selected)
    @setState(value: values)
    @props.onChange?(value: values)

  render: ->
    <select ref='categorySelect' multiple value={@state.value} disabled={@props.disabled}>
      <option value='-1'>ALL</option>
      {@renderOptions()}
    </select>

  renderOptions: ->
    for productCategory in @state.productCategories
      <option value={productCategory.id}>{productCategory.name}</option>
