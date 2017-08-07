# @cjsx
@CPA.Base.WorksInput = React.createClass

  getInitialState: ->
    works: {}

  componentDidMount: ->
    CPA.Actions.Works.loadAll()
    CPA.Stores.Works.on 'change', @updateWorks
    $(React.findDOMNode(@refs.select)).select2().on('change', @updateValue)

  componentWillUnmount: ->
    CPA.Stores.Works.off 'change', @updateWorks
    $(React.findDOMNode(@refs.select)).select2('destroy')

  componentDidUpdate: (prevProps, prevState) ->
    if prevState.works != @state.works
      $(React.findDOMNode(@refs.select)).change()

  updateWorks:(works) ->
    @setState(works: works)

  updateValue: (e) ->
    values = (option.value for option in e.target.options when option.selected)
    @props.onChange?(value: values)

  render: ->
    <select ref='select' multiple disabled={@props.disabled} value={@props.value} style={{width: '400px'}}>
      <option />
      {@renderOptions()}
    </select>

  renderOptions: ->
    return unless @state.works
    for work in @state.works
      <option value={work.gid}>{"#{work.model} #{work.name} - #{work.id}"}</option>
