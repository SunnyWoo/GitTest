# global 抛单到 cn 会将图片先传到 qiniu
# 用copy的方式节省掉 下载 处理 再上传 的过程
module DeliverOrder
  module Receiver
    class China < Base
      private

      def create_archived_work(work, product)
        archived_work = init_archived_work(work['name'], product)

        copy_file(archived_work, :cover_image, work['cover_image'])
        copy_file(archived_work, :print_image, work['print_image'])

        archived_work
      end

      def create_archived_standardized_work(work, product)
        archived_work = init_archived_standardized_work(work['name'], product)

        preview = archived_work.previews.create(key: 'order-image')
        copy_file(preview, :image, work['order_image'])
        copy_file(archived_work, :print_image, work['print_image'])

        archived_work
      end

      def copy_file(object, mounted_as, path)
        return if path.blank? || object.blank?
        file_identifier = path.split('/').last
        object.update_column(mounted_as, file_identifier)
        origin_bucket = Settings.deliver_order.qiniu.bucket # 这个值需要和global端的设置一样
        object.send(mounted_as).file.copy_from(path, origin_bucket)
        object.send(mounted_as).recreate_versions!
      rescue ::CarrierWave::IntegrityError => e
        return unless mounted_as.in?([:cover_image, :print_image])
        deliver_error_collections << ::DeliverErrorCollection.create!(workable: object,
                                                                      error_messages: { error: e },
                                                                      "#{mounted_as.to_s}_url": QiniuUploader.new.download_url(path))
      end

      def build_order_params
        base_order_params.merge(currency: 'CNY', message: 'delivered from TW')
      end

      def deliver_address
        {
          address_name: 'delivery',
          name: '我印網路科技有限公司',
          email: 'hi@commandp.com',
          address: '南京東路 5 段 16 號 3 樓',
          city: '台北市',
          zip_code: '105',
          country_code: 'TW',
          phone: '+886-2-2753-3555',
          shipping_way: 0
        }
      end
    end
  end
end
