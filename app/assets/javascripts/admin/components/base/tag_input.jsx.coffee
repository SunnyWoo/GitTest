# @cjsx
@CPA.Base.TagInput = React.createClass
  getInitialState: ->
    tags: []
    value: @props.value

  updateValue: (e) ->
    values = (option.value for option in e.target.options when option.selected)
    @setState(value: values)
    @props.onChange?(value: values)

  componentDidMount: ->
    $.getJSON('/admin/tags').success (data) =>
      @setState(tags: data.tags)
      $(React.findDOMNode(this.refs.tagSelect)).select2({tags: true}).on('change', (e) =>
        @updateValue(e)
      )

  componentWillUnmount: ->
    @setState(value: [])
    @props.onChange?(value: [])
    $(React.findDOMNode(this.refs.tagSelect)).select2('destroy')

  render: ->
    <select ref='tagSelect' multiple value={@state.value}>
      {@renderOptions()}
    </select>

  renderOptions: ->
    for tag in @state.tags
      <option value={tag.id}>{tag.name}</option>
