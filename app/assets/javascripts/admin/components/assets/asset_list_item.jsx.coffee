# @cjsx

@CPA.Assets.AssetListItem = React.createClass
  disableColorize: ->
    CPA.Actions.Assets.disableColorize(@props.asset)

  enableColorize: ->
    CPA.Actions.Assets.enableColorize(@props.asset)

  render: ->
    <div className='media'>
      <div className='pull-left'>
        <img className='assets-image dashed-border' src={@props.asset.image} alt={@props.asset.type} />
      </div>

      <div className='media-body'>
        <p>Type: {@props.asset.type}</p>
        <p>Colorizable: {if @props.asset.colorizable then 'Yes' else 'No'} {@renderToggleColorizableButton()}</p>
      </div>
    </div>

  renderToggleColorizableButton: ->
    if @props.asset.colorizable
      <button className='btn btn-xs' onClick={@disableColorize}>Disable</button>
    else
      <button className='btn btn-xs' onClick={@enableColorize}>Enable</button>
