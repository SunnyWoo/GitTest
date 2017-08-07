# @cjsx

@CPA.HomeBlocks.BlockItems = React.createClass
  mixins: [
    CPA.FluxMixin
    Fluxxor.StoreWatchMixin('HomeBlockStore', 'HomeBlockItemStore')
  ]

  getStateFromFlux: ->
    block: @getFlux().store('HomeBlockStore').get(@props.blockId)
    blockItems: @getFlux().store('HomeBlockItemStore').getAll(blockId: @props.blockId)

  createBlockItem: ->
    @getFlux().actions.createHomeBlockItem(blockId: @props.blockId)

  render: ->
    blockItems = for blockItem in @state.blockItems
                   <CPA.HomeBlocks.BlockItem key={blockItem.id} blockItemId={blockItem.id} />
    classes = switch @state.block.template
                when 'collection_2' then 'block-grid block-grid-xs-2'
                when 'collection_3' then 'block-grid block-grid-xs-3'
                when 'collection_4' then 'block-grid block-grid-xs-4'

    <div className='home-block-items'>
      <div className={classes}>
        {blockItems}
      </div>
      <button className='btn btn-xs btn-success' onClick={@createBlockItem}>Add Block Item</button>
    </div>
