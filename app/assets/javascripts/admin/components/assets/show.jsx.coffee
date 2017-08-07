# @cjsx

@CPA.Assets.Show = React.createClass
  getInitialState: ->
    detail: true
    columns: 1

  componentDidMount: ->
    CPA.Stores.Assets.on('load',   @updateFromStore)
    CPA.Stores.Assets.on('update', @updateFromStore)
    CPA.Actions.AssetPackages.show(@props.id)
    CPA.Actions.Assets.loadAll(@props.id)

  componentWillUnmount: ->
    CPA.Stores.Assets.off('load',   @updateFromStore)
    CPA.Stores.Assets.off('update', @updateFromStore)

  updateFromStore: (assetPackage) ->
    @forceUpdate()

  setDetail: ->
    @setState(columns: 1, detail: true)

  setPreviewColumn: (columns) -> ->
    @setState(columns: columns, detail: false)

  render: ->
    assetPackage = CPA.Stores.Assets.getPackage()

    <div>
      <CPA.Base.Link href='/' className='btn btn-default'>Back</CPA.Base.Link>
      <CPA.Base.Link href={"/#{assetPackage.id}/edit"} className='btn btn-default'>Edit</CPA.Base.Link>
      <h1>{assetPackage.name} <small>by {assetPackage.designer?.displayName}</small></h1>

      <button className='btn btn-default btn-sm' onClick={@setDetail}>Detail</button>
      <button className='btn btn-default btn-sm' onClick={@setPreviewColumn(2).bind(@)}>2 columns</button>
      <button className='btn btn-default btn-sm' onClick={@setPreviewColumn(3).bind(@)}>3 columns</button>

      <div className={"block-grid-xs-#{@state.columns} #{'assets-preview-container' unless @state.detail}"}>
        {@renderAssets()}
      </div>
    </div>

  renderAssets: ->
    assets = CPA.Stores.Assets.getAll()

    for asset in assets
      <div className='block-grid-item'>{@renderAssetContent(asset)}</div>

  renderAssetContent: (asset) ->
    if @state.detail
      <CPA.Assets.AssetListItem asset={asset} />
    else
      <img className='assets-image' src={asset.image} alt={asset.type} />
