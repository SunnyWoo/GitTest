module DeliverOrder
  module Receiver
    class Base
      attr_accessor :query, :archived_works, :deliver_error_collections

      def initialize(query)
        @query = query
        @archived_works ||= []
        @deliver_error_collections ||= []
      end

      def create
        return if Order.exists?(remote_id: query['order_id'])
        setup_order
        @order.pay!
        @order.approve!
        deliver_error_collections.each { |error_collection| error_collection.update_column(:order_id, @order.id) }
        @order.deliver_error_collections.each(&:repair_images_sync) if @order.deliver_error_collections.present?
      end

      private

      def delivery_user
        @user ||= User.find_by!(email: 'deliverorder@commandp.com')
      end

      def find_product(remote_key)
        ProductModel.find_by!(key: remote_key)
      end

      def setup_order
        Order.transaction do
          @order = Order.new(user: delivery_user,
                             remote_id: query['order_id'],
                             remote_info: { order_no: query['order_no'], single_item: query['single_item'] })

          @order.build_order(build_order_params)
          clear_coupon_when_not_satisfy
          @order.save!
        end
      end

      def init_archived_work(work_name, product)
        params = { delivery_order: true,
                   product: product,
                   user: delivery_user,
                   name: work_name,
                   prices: product.prices.to_h,
                   product_code: "#{product.product_code}-0001-000" }

        ArchivedWork.create!(params)
      end

      def init_archived_standardized_work(work_name, product)
        params = { product: product,
                   user: delivery_user,
                   name: work_name,
                   product_code: "#{product.product_code}-0001-000" }

        ArchivedStandardizedWork.create!(params)
      end

      def normalized_items
        query['order_items'].map do |item|
          itemable = create_itemable(item)

          { 'work_gid' => itemable.to_gid_param, 'quantity' => item['quantity'], 'remote_id' => item['item_id'] }
        end
      end

      def create_itemable(item)
        product = find_product(item['work']['remote_product_key'])
        if item['itemable_type'] =~ /^Work$|^ArchivedWork$/
          create_archived_work(item['work'], product)
        elsif item['itemable_type'] =~ /^StandardizedWork$|^ArchivedStandardizedWork$/
          create_archived_standardized_work(item['work'], product)
        end
      end

      def base_order_params
        {
          payment: query['payment'],
          coupon: Settings.deliver_order.coupon_code,
          billing_info: deliver_address,
          shipping_info: deliver_address,
          order_items: normalized_items,
        }
      end

      def clear_coupon_when_not_satisfy
        @order.coupon = nil unless @order.send(:validates_should_satisfy_coupon_condition).nil?
      end

      def create_archived_work
        fail 'Not yet implemented.'
      end

      def create_archived_standardized_work
        fail 'Not yet implemented.'
      end

      def build_order_params
        fail 'Not yet implemented.'
      end
    end
  end
end
