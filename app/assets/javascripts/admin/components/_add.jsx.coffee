window.CmdpAdmin.AddFilter = React.createClass
  getInitialState: ->
    filterAPI: ''
    platformKey: ''
    platformName: ''
    valueKey: ['---']
    valueName: ['---']
    platformSelected: ''
    valueSelected: ''

  componentDidMount: ->
    filterData = filtersInit()
    filterData.done (response)=>
      platformName = _.map response.filter, 'name'
      platformKey = _.map response.filter, 'key'
      @setState
        filterAPI: response
        platformKey: platformKey
        platformName: platformName
      return

  onPlatformChange: (e)->
    hasSelected = []
    hasSelectedName = []
    for x in @props.hasSelected
      hasSelected.push(x.value)
      hasSelectedName.push(x.valueName)
    if e.target.value isnt '---'
      subOptions = _.where @state.filterAPI.filter, { 'key': e.target.value }
      value = _.map subOptions[0].values, 'name'
      value = _.difference value, hasSelectedName
      value.unshift('---')
      valueKey = _.map subOptions[0].values, 'key'
      valueKey = _.difference valueKey, hasSelected
      valueKey.unshift('---')
      @setState
        platformSelected: e.target.value
        valueKey: valueKey
        valueName: value
      document.querySelector('.add-filter .value [value="---"]').selected = true;
    else
      @setState
        valueKey: ['---']
        valueName: ['---']

  onValueChange: (e)->
    thisPlatform = _.where @state.filterAPI.filter, { 'key': @state.platformSelected }
    for x in thisPlatform[0].values
      if x.key is e.target.value
        thisValue = x.name
    @props.onAddFilter(thisPlatform[0].name, @state.platformSelected, thisValue, e.target.value)
    return

  render: ->
    if this.props.filterShow
      `<li className='add-filter'>
        <CmdpAdmin.PlatformOptions platformKey={this.state.platformKey} platformName={this.state.platformName} onPlatformChange={this.onPlatformChange} />
        <CmdpAdmin.PlatformValue valueKey={this.state.valueKey} valueName={this.state.valueName} onValueChange={this.onValueChange} />
      </li>`
    else
      `<li></li>`