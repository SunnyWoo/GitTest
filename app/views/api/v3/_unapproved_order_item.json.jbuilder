cache_json_for json, order_item do
  json.name order_item.itemable.name
  json.links do
    if order_item.itemable.is_a?(ArchivedStandardizedWork)
      json.edit url_for([:edit, :admin, order_item.itemable.original_work, locale: I18n.locale])
    else
      json.edit url_for([:edit, :admin, order_item.itemable, locale: I18n.locale])
    end
    json.create_note admin_noteable_notes_path(order_item)
  end
  json.images do
    json.order_image do
      json.thumb order_item.itemable_order_image.thumb.url
      json.origin order_item.itemable_order_image.url
    end
    json.cover_image do
      if order_item.itemable_cover_image.present?
        json.thumb order_item.itemable_cover_image.thumb.url
        json.origin order_item.itemable_cover_image.url
      else
        json.thumb nil
        json.origin nil
      end
    end
    json.print_image do
      if order_item.itemable.is_a?(StandardizedWork) || order_item.itemable.is_a?(ArchivedStandardizedWork)
        json.thumb order_item.itemable.previews.first.image.thumb.url
        json.origin order_item.itemable.previews.first.image.url
      else
        json.thumb order_item.itemable_print_image.thumb.url
        json.origin order_item.itemable_print_image.url
      end
    end
  end
  json.notes do
    json.partial! 'api/v3/note', collection: order_item.notes, as: :note
  end
end
