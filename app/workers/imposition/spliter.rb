class Imposition::Spliter
  include Sidekiq::Worker

  def perform(factory_id, product_id, item_ids)
    product = ProductModel.find(product_id)

    delivery_order = DeliveryOrder.create(product: product, print_item_ids: item_ids)
    Imposition::DeliveryOrderUploader.perform_async(delivery_order.id, factory_id)

    imposition = product.imposition || Imposition::Niflheim.instance
    imposition.each_slice_with_index(item_ids) do |slice, index|
      Imposition::ImpositionUploader.perform_async(factory_id, product_id, slice, delivery_order.upload_path, (index + 1))
    end
  end
end
