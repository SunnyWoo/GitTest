module Region
  VALID_REGIONS = %w(china global)

  def self.region
    VALID_REGIONS.include?(ENV['REGION']) ? ENV['REGION'] : 'global'
  end

  def self.china?
    region == 'china'
  end

  def self.global?
    !china?
  end

  def self.default_locale
    china? ? 'zh-CN' : 'en'
  end

  def self.default_currency
    china? ? 'CNY' : 'TWD'
  end
end
