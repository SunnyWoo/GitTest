# @cjsx
@CPA.PriceTiers.App = React.createClass
  getInitialState: ->
    editing: false
    priceTiers: new CPA.PriceTiers.PriceTiers(@props.priceTiers, @props.currencies)

  getDefaultProps: ->
    priceTiers: [
      { tier: 1, TWD: 10, HKD:  5, JPY: 30 }
      { tier: 2, TWD: 20, HKD: 10, JPY: 60 }
      { tier: 3, TWD: 30, HKD: 15, JPY: 90 }
    ]
    currencies: ['TWD', 'HKD', 'JPY']

  edit: ->
    @setState(editing: true, originalPriceTiers: @state.priceTiers.clone())

  update: ->
    if @state.priceTiers.isValid()
      $.ajax(
        type: 'PUT'
        url: @props.url
        data:
          changeset: @state.priceTiers.getChangeset()
        success: (data) =>
          priceTiers = new CPA.PriceTiers.PriceTiers(data.price_tiers, @props.currencies)
          @setState(priceTiers: priceTiers)
      )
      @setState(editing: false)

  cancel: ->
    @setState(editing: false, priceTiers: @state.originalPriceTiers)

  add: ->
    @state.priceTiers.add()
    @setState(priceTiers: @state.priceTiers)

  updatePriceTiers: (e) ->
    @setState(priceTiers: e.value)

  render: ->
    <div>
      {@renderEditToolbar()}
      <CPA.PriceTiers.Table priceTiers={@state.priceTiers}
                            currencies={@props.currencies}
                            editing={@state.editing}
                            onChange={@updatePriceTiers} />
      {@renderAddButton()}
    </div>

  renderEditToolbar: ->
    if @state.editing
      <div className="text-right">
        <button className="btn btn-normal" onClick={@update}>Update</button>
        <button className="btn btn-link" onClick={@cancel}>Cancel</button>
      </div>
    else
      <div className="text-right">
        <button className="btn btn-normal" onClick={@edit}>Edit</button>
      </div>

  renderAddButton: ->
    if @state.editing
      <div className="text-center">
        <button className="btn btn-normal" onClick={@add}>Add</button>
      </div>
