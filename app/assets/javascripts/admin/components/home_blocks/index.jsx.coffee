# @cjsx

@CPA.HomeBlocks.Index = React.createClass
  mixins: [
    CPA.FluxMixin
    Fluxxor.StoreWatchMixin('HomeBlockStore', 'HomeBlockItemStore')
  ]

  componentDidMount: ->
    @getFlux().actions.getAllHomeBlocks()
    @getFlux().actions.getAllHomeBlockItems()

  getStateFromFlux: ->
    blocks: @getFlux().store('HomeBlockStore').getAll()

  createBlock: ->
    @getFlux().actions.createHomeBlock()

  render: ->
    blocks = (<CPA.HomeBlocks.Block key={block.id} blockId={block.id} /> for block in @state.blocks)

    <div>
      {blocks}
      <button className='btn btn-success' onClick={@createBlock}>Add Block</button>
    </div>
