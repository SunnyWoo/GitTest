# @cjsx
@CPA.Base.CountriesInput = React.createClass
  componentDidMount: ->
    CPA.Actions.Countries.loadAll()
    CPA.Stores.Countries.on 'change', @updateCountries

  componentWillUnmount: ->
    CPA.Stores.Countries.off 'change', @updateCountries

  updateCountries: ->
    @setState(countries: CPA.Stores.Countries.getAll())

  toggleValue: (code) -> ->
    newValue = if @isChecked(code)
                 _.without(@props.value, code)
               else
                 @props.value.concat([code])
    @props.onChange?(value: newValue)

  render: ->
    <div className={@props.className}>
      {@renderOptions()}
    </div>

  renderOptions: ->
    for country in CPA.Stores.Countries.getAll()
      <div className='block-grid-item'>
        <label><input type="checkbox" value={country.code}
                      checked={@isChecked(country.code)}
                      onChange={@toggleValue(country.code).bind(@)} /> {country.name}</label>
      </div>

  isChecked: (code) ->
    @props.value.indexOf(code) isnt -1 if @props.value
