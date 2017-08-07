# @cjsx

@CPA.Assets.ListItem = React.createClass
  getInitialState: ->
    dragging: false

  startDrag: (e) ->
    @setState(dragging: true)
    @props.onDragStart(e, @props.assetPackage)

  dragOver: (e) ->
    @props.onDragOver(e, @props.assetPackage)

  dragEnd: (e) ->
    @setState(dragging: false)
    @props.onDragEnd(e, @props.assetPackage)

  getDraggingStyle: ->
    opacity: if @state.dragging then 0.3 else 1

  getStatus: ->
    if @props.assetPackage.available
      beginAt = new Date(@props.assetPackage.beginAt or '2000-01-01')
      endAt   = new Date(@props.assetPackage.endAt   or '2100-01-01') # TODO: 希望子孫將來有幸能改到這行
      now     = new Date()
      switch
        when now < beginAt                 then 'Ready'
        when now > beginAt and now < endAt then 'On Board'
        when now > endAt                   then 'Off Board'
    else
      'Hidden'

  disable: -> CPA.Actions.AssetPackages.disable(@props.assetPackage)

  enable: -> CPA.Actions.AssetPackages.enable(@props.assetPackage)

  render: ->
    <div className='media' style={@getDraggingStyle()}
         onDragStart={@startDrag} onDragOver={@dragOver} onDragEnd={@dragEnd}>
      <hr />
      <div className='pull-left'>
        <img className='media-object' src={@props.assetPackage.icon or 'http://placehold.it/100x100'} alt={@props.assetPackage.name} />
      </div>
      <div className='media-body'>
        <div className='row'>
          <div className='col-sm-2'>
            <h3>{@props.assetPackage.name}</h3>
            <p>by {@props.assetPackage.designer?.displayName}</p>
          </div>
          <div className='col-sm-4'>
            <p>{@props.assetPackage.description}</p>
          </div>
          <div className='col-sm-3'>
            <p>Category: {@props.assetPackage.categoryName}</p>
            <p>Status: {@getStatus()}</p>
            <p>Start on: {@props.assetPackage.beginAt}</p>
            <p>End on: {@props.assetPackage.endAt}</p>
            <p>Downloads Count: {@props.assetPackage.downloadsCount}</p>
          </div>
          <div className='col-sm-3'>
            <p>DL: TODO</p>
            <p>
              <CPA.Base.Link href={"/#{@props.assetPackage.id}"} className='btn btn-xs'>Assets</CPA.Base.Link>
              {@renderToggleButton()}
              <CPA.Base.Link href={"/#{@props.assetPackage.id}/edit"} className='btn btn-xs'>Edit</CPA.Base.Link>
            </p>
          </div>
        </div>
      </div>
    </div>

  renderToggleButton: ->
    if @props.assetPackage.available
      <button className='btn btn-xs btn-danger' onClick={@disable}>Disable</button>
    else
      <button className='btn btn-xs btn-primary' onClick={@enable}>Enable</button>
