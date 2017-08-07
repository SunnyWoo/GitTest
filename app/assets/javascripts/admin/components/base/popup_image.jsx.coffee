# @cjsx

@CmdpAdmin.PopupImage = React.createClass
  propTypes:
    href: React.PropTypes.string

  componentDidMount: ->
    $(@refs.popupImage.getDOMNode()).magnificPopup
      type: 'image'

  render: ->
    <a ref='popupImage' href={@props.href}>{@props.children}</a>
