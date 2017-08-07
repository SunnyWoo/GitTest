#@cjsx

BootstrapModalMixin = do ->
  handlerProps = [
    'handleShow'
    'handleShown'
    'handleHide'
    'handleHidden'
  ]
  bsModalEvents = 
    handleShow: 'show.bs.modal'
    handleShown: 'shown.bs.modal'
    handleHide: 'hide.bs.modal'
    handleHidden: 'hidden.bs.modal'
  {
    propTypes:
      handleShow: React.PropTypes.func
      handleShown: React.PropTypes.func
      handleHide: React.PropTypes.func
      handleHidden: React.PropTypes.func
      backdrop: React.PropTypes.bool
      keyboard: React.PropTypes.bool
      show: React.PropTypes.bool
      remote: React.PropTypes.string
    getDefaultProps: ->
      {
        backdrop: true
        keyboard: true
        show: true
        remote: ''
      }
    componentDidMount: ->
      $modal = $(@getDOMNode()).modal(
        backdrop: @props.backdrop
        keyboard: @props.keyboard
        show: @props.show
        remote: @props.remote)
      handlerProps.forEach ((prop) ->
        if @[prop]
          $modal.on bsModalEvents[prop], @[prop]
        if @props[prop]
          $modal.on bsModalEvents[prop], @props[prop]
        return
      ).bind(this)
      return
    componentWillUnmount: ->
      $modal = $(@getDOMNode())
      handlerProps.forEach ((prop) ->
        if @[prop]
          $modal.off bsModalEvents[prop], @[prop]
        if @props[prop]
          $modal.off bsModalEvents[prop], @props[prop]
        return
      ).bind(this)
      return
    hide: ->
      $(@getDOMNode()).modal 'hide'
      return
    show: ->
      $(@getDOMNode()).modal 'show'
      return
    toggle: ->
      $(@getDOMNode()).modal 'toggle'
      return
    renderCloseButton: ->
      <button
        type="button"
        className="close"
        onClick={this.hide}
        dangerouslySetInnerHTML={{__html: '&times'}}
      />
  }


@CPA.Base.Modal = React.createClass
  mixins: [BootstrapModalMixin]

  render: ->
    buttons = @props.buttons.map (button) =>
      <button type="button" className={'btn btn-' + button.type} onClick={@props.onClick}>
        {button.text}
      </button>

    <div className="modal fade">
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            {@renderCloseButton()}
            <strong>{this.props.header}</strong>
          </div>
          <div className="modal-body">
            {@props.children}
          </div>
          <div className="modal-footer">
            {buttons}
          </div>
        </div>
      </div>
    </div>