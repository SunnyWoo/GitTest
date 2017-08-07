#= require jquery.fileupload
# @cjsx

@CPA.Assets.Index = React.createClass
  getInitialState: ->
    assetPackages: CPA.Stores.AssetPackages.getAll()

  componentDidMount: ->
    $(@refs.newPackage.getDOMNode())
      .fileupload(url: '/admin/asset_packages', paramName: 'file')
      .on('fileuploaddone', @onPackageUploadDone)
      .on('fileuploadfail', @onPackageUploadFail)

    CPA.Stores.AssetPackages.on('change', @updateFromStore)
    CPA.Actions.AssetPackages.loadAll()

  componentWillReceiveProps: (nextProps) ->
    CPA.Actions.AssetPackages.search(nextProps.filters)

  componentWillUnmount: ->
    $(@refs.newPackage.getDOMNode()).fileupload('destroy')
    CPA.Stores.AssetPackages.off('change', @updateFromStore)

  onPackageUploadDone: (e, data) ->
    assetPackage = humps.camelizeKeys(data.result).assetPackage
    CPA.Actions.AssetPackages.create(assetPackage)
    ReactMiniRouter.navigate("/#{assetPackage.id}/edit")

  onPackageUploadFail: (e, data) ->
    json = humps.camelizeKeys(JSON.parse(data.jqXHR.responseText))
    errorMessages = _.values(json).join('\n')
    CPA.Actions.Flash.error(errorMessages)

  updateFromStore: (assetPackages) ->
    @setState(assetPackages: assetPackages)

  dragStart: (e, assetPackage) ->
    index = @state.assetPackages.indexOf(assetPackage)
    @setState(dragging: { item: assetPackage, position: index, originalPosition: index })
    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData('text/html', null)

  dragOver: (e, assetPackage) ->
    e.preventDefault()

    from = @state.dragging.position
    to = @state.assetPackages.indexOf(assetPackage)

    to += 1 if @overMyDownBody(e)
    to -= 1 if from < to

    return if from is to

    item = @state.assetPackages.splice(from, 1)[0]
    @state.assetPackages.splice(to, 0, item)
    @state.dragging.position = to
    @forceUpdate()

  dragEnd: (e, assetPackage) ->
    prevItem = @state.assetPackages[@state.dragging.position - 1]
    nextItem = @state.assetPackages[@state.dragging.position + 1]
    insertPosition = switch
                       when prevItem then prevItem.position + 1
                       when nextItem then nextItem.position - 1
    if @state.dragging.position > @state.dragging.originalPosition
      insertPosition -= 1
    if insertPosition? and @state.dragging.position isnt @state.dragging.originalPosition
      CPA.Actions.AssetPackages.insertTo(@state.dragging.item, Math.max(insertPosition, 1))
    @setState(dragging: null)

  overMyDownBody: (e) ->
    top = 0
    el = e.currentTarget
    while el
      top += el.offsetTop
      el = el.offsetParent
    e.clientY > top + e.currentTarget.offsetHeight / 2

  sortBy: (sortType) ->
    sortedAssetPackages = _.sortBy(@state.assetPackages, (ap) ->
      switch sortType
        when 'downloads' then ap.downloadsCount
        when 'begins' then new Date(ap.beginAt)
        when 'ends' then new Date(ap.endAt)
      )
    @setState(assetPackages: sortedAssetPackages)

  render: ->
    rows = for assetPackage, i in @state.assetPackages
      <CPA.Assets.ListItem key={assetPackage.id} assetPackage={assetPackage} />
    <div>
      <div><CPA.Assets.Search filters={@props.filters} /></div>
      <div className="assets-sort">
        <CPA.Assets.Sort onChange={@sortBy} />
      </div>
      <div className="btn btn-app btn-file btn-primary radius-4">
        <input ref="newPackage" type="file" accept='application/zip,application/x-zip,application/x-zip-compressed' />
        <i className="ace-icon fa fa-cloud-upload bigger-230"></i>
        Upload
      </div>
      <div>
        <p>上傳檔案格式為ZIP，ZIP檔案結構『直接』包含sticker, coating, 或foiling資料夾，裡面才是存取圖片檔案，檔案類型為.png或.svg</p>
      </div>
      <div>
        {rows}
      </div>
    </div>
