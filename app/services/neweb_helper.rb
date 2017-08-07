require 'digest/md5'
require 'rack/utils'

module NewebHelper
  def md5(*args)
    Digest::MD5.hexdigest(args.join)
  end

  def parse_query(qs)
    Rack::Utils.parse_nested_query(qs)
  end

  # 藍新日期格式為 yyyyMMdd
  def to_neweb_date(date_or_time)
    return if date_or_time.blank?
    date_or_time.to_date.strftime('%Y%m%d')
  end

  # 藍新時間格式為 yyyyMMddHHmmss
  def to_neweb_time(date_or_time)
    return if date_or_time.blank?
    date_or_time.to_time.strftime('%Y%m%d%H%M%S')
  end

  # 檢查是否給了所有需要的欄位
  def check_required_fields(options, *fields)
    missing_fields = fields - options.keys
    if missing_fields.any?
      raise "Missing required fields: #{missing_fields.join(', ')}"
    end
  end
end
