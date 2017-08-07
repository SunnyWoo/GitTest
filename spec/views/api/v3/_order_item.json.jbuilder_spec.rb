require 'spec_helper'

RSpec.describe 'api/v3/_order_item.json.jbuilder', :caching, type: :view do
  let(:order_item) do
    create(:order_item, order: create(:order))
  end

  it 'renders order item' do
    render 'api/v3/order_item', order_item: order_item
    expect(JSON.parse(rendered)).to eq(
      'quantity' => order_item.quantity,
      'price' => order_item.price_in_currency(order_item.order.currency),
      'work_uuid' => order_item.itemable_uuid,
      'work_name' => order_item.itemable_name,
      'model_name' => order_item.itemable.product_name,
      'model_key' => order_item.itemable.product.key,
      'product_name' => order_item.itemable.product_name,
      'product_key' => order_item.itemable.product.key,
      'order_image' => order_item.itemable.order_image.thumb.url,
      'name' => order_item.itemable.name,
      'links' => { 'edit' => view.url_for([:edit, :admin, order_item.itemable, locale: I18n.locale]),
                   'create_note' => view.admin_noteable_notes_path(order_item) },
      'images' => {
        'order_image' => { 'thumb' => order_item.itemable_order_image.thumb.url,
                           'origin' => order_item.itemable_order_image.url },
        'cover_image' => { 'thumb' => order_item.itemable_cover_image.thumb.url,
                           'origin' => order_item.itemable_cover_image.url },
        'print_image' => { 'thumb' => order_item.itemable_print_image.thumb.url,
                           'origin' => order_item.itemable_print_image.url }
      },
      'notes' => order_item.notes.map do |note|
        {
          'id' => note.id,
          'message' => note.message,
          'created_at' => note.created_at.as_json,
          'user_email' => note.user_email,
          'links' => {
            'update' => view.polymorphic_path([:admin, note.noteable, note], locale: I18n.locale)
          }
        }
      end,
      'user_display_name' => order_item.itemable.user_display_name,
      'is_public' => order_item.itemable.is_public?
    )
  end
end
