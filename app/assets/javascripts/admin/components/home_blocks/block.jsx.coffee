# @cjsx

@CPA.HomeBlocks.Block = React.createClass
  mixins: [
    CPA.FluxMixin
    Fluxxor.StoreWatchMixin('HomeBlockStore', 'HomeBlockItemStore')
  ]

  getInitialState: ->
    editingTitle: false

  getStateFromFlux: ->
    block: @getFlux().store('HomeBlockStore').get(@props.blockId)
    blockItems: @getFlux().store('HomeBlockItemStore').getAll(blockId: @props.blockId)

  updateTemplate: (e) ->
    @getFlux().actions.updateHomeBlock(@state.block, template: e.target.value)

  editTitle: ->
    @setState(editingTitle: true, titleTranslations: @state.block.titleTranslations)

  updateEditingTitle: (e) ->
    @setState(titleTranslations: e.value)

  submitTitle: ->
    @getFlux().actions.updateHomeBlock(@state.block, titleTranslations: @state.titleTranslations)
    @setState(editingTitle: false)

  removeBlock: ->
    if confirm('Are you sure?')
      @getFlux().actions.destroyHomeBlock(@state.block)

  render: ->
    <div className='home-block'>
      <div className='home-block-id'>Block #{@state.block.id}</div>
      {@renderTitle()}
      Template: <CPA.Base.SelectInput value={@state.block.template} collection={@collections()} onChange={@updateTemplate} />
      <CPA.HomeBlocks.BlockItems blockId={@state.block.id} />
    </div>

  collections: ->
    [
      { value: 'collection_2', label: 'collection_2' }
      { value: 'collection_3', label: 'collection_3' }
      { value: 'collection_4', label: 'collection_4' }
    ]

  renderTitle: ->
    if @state.editingTitle
      <div>
        <CPA.Base.TranslationsInput value={@state.titleTranslations} onChange={@updateEditingTitle} />
        <button className='btn btn-xs btn-primary' onClick={@submitTitle}>
          <i className='fa fa-pencil-square-o' /> Submit
        </button>
      </div>
    else
      <h1 className='text-center'>
        {@state.block.title or '(Untitled)'}
        <button className='btn btn-xs btn-default' onClick={@editTitle}>
          <i className='fa fa-pencil-square-o' /> Edit
        </button>
        <button className='btn btn-xs btn-danger' onClick={@removeBlock}>
          <i className='fa fa-pencil-square-o' /> Remove
        </button>
      </h1>
