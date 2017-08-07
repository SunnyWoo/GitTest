module Extensions
  module CarrierWave
    module Storage
      module Connection
        # http://developer.qiniu.com/code/v6/sdk/ruby.html#rs-copy
        # Qiniu::Storage.copy Example:
        #  Qiniu::Storage.copy(
        #      bucket,     # 源存储空间
        #      key,        # 源资源名
        #      dst_bucket,     # 目标存储空间
        #      dst_key         # 目标资源名
        #  )
        #
        # Overwrite for support copy from one bucket to another bucket
        def copy(origin, target, origin_bucket=nil, target_bucket=nil)
          origin_bucket ||= @qiniu_bucket
          target_bucket ||= @qiniu_bucket
          resp_code, resp_body, = ::Qiniu::Storage.copy(origin_bucket, origin, target_bucket, target)
          if resp_code < 200 or resp_code >= 300
            raise ::CarrierWave::IntegrityError, "Copy failed, status code: #{resp_code}, response: #{resp_body}"
          end
        end
      end

      module File
        def extension
          path.split('.').last
        end

        def exists?
          return true if qiniu_connection.stat(path).present?
          false
        end

        # Overwrite for support copy from another bucket
        def copy_from(origin_path, origin_bucket=nil)
          qiniu_connection.delete(@path)

          qiniu_connection.copy(origin_path, @path, origin_bucket)
        end
      end
    end
  end
end
