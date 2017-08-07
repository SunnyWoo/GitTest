# @cjsx

@CPA.HomeBlocks.BlockItem = React.createClass
  mixins: [
    CPA.FluxMixin
    Fluxxor.StoreWatchMixin('HomeBlockItemStore')
  ]

  getInitialState: ->
    editingTitle: false
    editingSubtitle: false
    editingHref: false

  getStateFromFlux: ->
    blockItem: @getFlux().store('HomeBlockItemStore').get(@props.blockItemId)

  editTitle: ->
    @setState(editingTitle: true, titleTranslations: @state.blockItem.titleTranslations)

  updateEditingTitle: (e) ->
    @setState(titleTranslations: e.value)

  submitTitle: ->
    @getFlux().actions.updateHomeBlockItem(@state.blockItem, titleTranslations: @state.titleTranslations)
    @setState(editingTitle: false)

  editSubtitle: ->
    @setState(editingSubtitle: true, subtitleTranslations: @state.blockItem.subtitleTranslations)

  updateEditingSubtitle: (e) ->
    @setState(subtitleTranslations: e.value)

  submitSubtitle: ->
    @getFlux().actions.updateHomeBlockItem(@state.blockItem, subtitleTranslations: @state.subtitleTranslations)
    @setState(editingSubtitle: false)

  editHref: ->
    @setState(editingHref: true, href: @state.blockItem.href)

  updateEditingHref: (e) ->
    @setState(href: e.target.value)

  submitHref: ->
    @getFlux().actions.updateHomeBlockItem(@state.blockItem, href: @state.href)
    @setState(editingHref: false)

  removeBlockItem: ->
    if confirm('Are you sure?')
      @getFlux().actions.destroyHomeBlockItem(@state.blockItem)

  reloadAllBlockItems: ->
    @getFlux().actions.getAllHomeBlockItems()

  render: ->
    <div className='home-block-item block-grid-item'>
      <div className='well well-xs'>
        <div className='home-block-item-id'>BlockItem #{@state.blockItem.id}</div>
        <div className='clearfix'>
          <CPA.HomeBlocks.TranslationsImageInput blockItemId={@props.blockItemId}
                                                 picTranslations={@state.blockItem.picTranslations}
                                                 onChange={@reloadAllBlockItems} />
        </div>
        {@renderTitle()}
        {@renderSubtitle()}
        {@renderHref()}
        <button className='btn btn-xs btn-danger' onClick={@removeBlockItem}>
          <i className='fa fa-pencil-square-o' /> Remove
        </button>
      </div>
    </div>

  renderTitle: ->
    if @state.editingTitle
      <div>
        <CPA.Base.TranslationsInput value={@state.titleTranslations} onChange={@updateEditingTitle} vertical />
        <button className='btn btn-xs btn-primary' onClick={@submitTitle}>
          <i className='fa fa-pencil-square-o' /> Submit
        </button>
      </div>
    else
      <h2 className='home-block-item-title'>
        {@state.blockItem.title or '(no title)'}
        <button className='btn btn-xs btn-default' onClick={@editTitle}>
          <i className='fa fa-pencil-square-o' /> Edit
        </button>
      </h2>

  renderSubtitle: ->
    if @state.editingSubtitle
      <div>
        <CPA.Base.TranslationsInput value={@state.subtitleTranslations} onChange={@updateEditingSubtitle} vertical />
        <button className='btn btn-xs btn-primary' onClick={@submitSubtitle}>
          <i className='fa fa-pencil-square-o' /> Submit
        </button>
      </div>
    else
      <div className='home-block-item-subtitle'>
        {@state.blockItem.subtitle or '(no subtitle)'}
        <button className='btn btn-xs btn-default' onClick={@editSubtitle}>
          <i className='fa fa-pencil-square-o' /> Edit
        </button>
      </div>

  renderHref: ->
    if @state.editingHref
      <input className='form-control' value={@state.href}
             onChange={@updateEditingHref} onBlur={@submitHref} autoFocus />
    else
      <div className='home-block-item-href'>
        {@state.blockItem.href or '(no href)'}
        <button className='btn btn-xs btn-default' onClick={@editHref}>
          <i className='fa fa-pencil-square-o' /> Edit
        </button>
      </div>
