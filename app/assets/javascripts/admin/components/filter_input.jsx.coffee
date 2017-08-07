# @cjsx

@CmdpAdmin.FilterInput = React.createClass
  propTypes:
    type: React.PropTypes.string
    value: React.PropTypes.string
    filterID: React.PropTypes.number
    onChange: React.PropTypes.func.isRequired
    onDelete: React.PropTypes.func.isRequired

  getInitialState: ->
    filtersCollection: [
      {value: '',         label: 'Select type...'}
      {value: 'startAt',  label: 'Start at'}
      {value: 'endAt',    label: 'End at'}
      {value: 'platform', label: 'Platform'}
      {value: 'country',  label: 'Country'}
    ]

    filters: 
      startAt:  'DateInput'
      endAt:    'DateInput'
      platform: 'SelectInput'
      country:  'SelectInput'

    type: @props.type
    value: @props.value

  render: ->
    # value should fetch from hashbang url
    <div className="rc-filter-input">
      <CmdpAdmin.SelectInput value={@state.type}
                             onChange={@setType}
                             collection={@state.filtersCollection} />
      {@valueInput()}
      <i className="del fa fa-times" onClick={@deleteFilter}></i>
    </div>

  setType: (e) ->
    @setState(type: e.target.value, value: '')
    pair = { type: e.target.value, value: '' }
    @props.onChange(pair: pair)

  setValue: (e) ->
    @setState(value: e.target.value)
    pair = { type: @state.type, value: e.target.value }
    @props.onChange(pair: pair)

  deleteFilter: (e) ->
    @props.onDelete(@props.filterID)

  valueInput: ->
    @["#{@state.type}Input"]?()

  startAtInput: ->
    <CmdpAdmin.DateInput value={@state.value} onChange={@setValue} />

  endAtInput: ->
    <CmdpAdmin.DateInput value={@state.value} onChange={@setValue} />

  platformInput: ->
    platformsCollection = [
      {value: '',        label: 'Select Platform...'}
      {value: '',        label: 'All'}
      {value: 'iOS',     label: 'iOS'}
      {value: 'Web',     label: 'Web'}
      {value: 'Android', label: 'Android'}
    ]
    <CmdpAdmin.SelectInput value={@state.value}
                           onChange={@setValue}
                           collection={platformsCollection} />

  countryInput: ->
    countryCollection = [
      {value: '',    label: 'Select Country...'}
      {value: '',    label: 'All'}
      {value: 'AU',  label: 'Australia'}
      {value: 'CA',  label: 'Canada'}
      {value: 'CN',  label: 'China'}
      {value: 'FR',  label: 'France'}
      {value: 'DE',  label: 'Germany'}
      {value: 'HK',  label: 'Hong Kong'}
      {value: 'JP',  label: 'Japan'}
      {value: 'MO',  label: 'Macao'}
      {value: 'MY',  label: 'Malaysia'}
      {value: 'NZ',  label: 'New Zealand'}
      {value: 'SG',  label: 'Singapore'}
      {value: 'KR',  label: 'South Korea'}
      {value: 'TW',  label: 'Taiwan'}
      {value: 'GB',  label: 'United Kingdom'}
      {value: 'US',  label: 'United States'}
    ]
    <CmdpAdmin.SelectInput value={@state.value}
                           onChange={@setValue}
                           collection={countryCollection} />