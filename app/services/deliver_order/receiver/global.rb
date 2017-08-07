module DeliverOrder
  module Receiver
    class Global < Base
      private

      def create_archived_work(work, product)
        archived_work = init_archived_work(work['name'], product)

        archived_work.remote_cover_image_url = work['cover_image']
        archived_work.remote_print_image_url = work['print_image']
        if archived_work.valid?
          archived_work.save!
        else
          error_collect = DeliverErrorCollection.new(workable: archived_work,
                                                     error_messages: archived_work.errors.to_hash)
          error_collect.cover_image_url = work['cover_image']
          error_collect.print_image_url = work['print_image']
          error_collect.save!
          deliver_error_collections << error_collect
        end

        archived_work
      end

      def create_archived_standardized_work(work, product)
        archived_work = init_archived_standardized_work(work['name'], product)

        archived_work.previews.create(key: 'order-image', remote_image_url: work['order_image'])

        unless archived_work.update_attributes(remote_print_image_url: work['print_image'])
          deliver_error_collections << DeliverErrorCollection.create!(workable: archived_work,
                                                                      error_messages: archived_work.errors.to_hash,
                                                                      print_image_url: work['print_image'])
        end

        archived_work
      end

      def build_order_params
        base_order_params.merge(currency: 'TWD', message: 'delivered from CN')
      end

      def deliver_address
        {
          address_name: 'delivery',
          name: '优印(上海)信息科技有限公司',
          email: 'hi@commandp.com',
          address: '青浦区外青松公路 3777 弄 55 号',
          city: '上海市',
          zip_code: '201700',
          country_code: 'CN',
          phone: '+86-021-5472-6632',
          shipping_way: 0
        }
      end
    end
  end
end
