#@cjsx

@CPA.Unapproved.OrderItem = React.createClass
  propTypes:
    itemID: React.PropTypes.string
    item: React.PropTypes.object

  componentDidMount: ->
    $(@refs.popupGallery.getDOMNode()).magnificPopup
      delegate: 'a'
      type: 'image'
      gallery:
        enabled:true

  render: ->
    <div>
      <h3>{@props.item.model_name}</h3>
      <div><a href={@props.item.links.edit}>Edit Work</a></div>
      <table className="show-order-item table table-striped table-bordered">
        <thead>
          <tr>
            <th>Order image</th>
            <th>Cover image</th>
            <th>Print image</th>
          </tr>
        </thead>
        <tbody>
          <tr className="popup-gallery" ref="popupGallery">
            <td>
              <a href={@props.item.images.order_image.origin} title="Order image" target="_blank">
                <img className="lazy" src={@props.item.images.order_image.thumb} />
              </a>
            </td>
            <td>
              <a href={@props.item.images.cover_image.origin} title="Cover image" target="_blank">
                <img className="lazy" src={@props.item.images.cover_image.thumb} />
              </a>
            </td>
            <td>
              <a href={@props.item.images.print_image.origin} title="Print image" target="_blank">
                <img className="lazy" src={@props.item.images.print_image.thumb} />
              </a>
            </td>
          </tr>
        </tbody>
      </table>
      <CPA.Unapproved.Note orderID={'note_'+@props.itemID}
                           createUrl={@props.item.links.create_note}
                           notes={@props.item.notes}/>
    </div>