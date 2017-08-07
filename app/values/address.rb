class Address
  # country
  # country_code
  # province
  # state
  # city
  # district
  # zip_code / postal_code
  # dist_code
  FIELDS = %w(country province state city dist zip_code address).freeze
  ALL_FIELDS = FIELDS + %w(dist_code country_code province_id)

  attr_reader :data

  delegate :present?, :as_json, to: :data

  class << self
    def dump(object)
      object.as_json
    end

    def load(hash)
      new(hash)
    end
  end

  def initialize(data = nil)
    @data = {}
    hash = Hash(data).stringify_keys
    ALL_FIELDS.each do |key|
      send("#{key}=", hash[key]) if hash.key?(key)
    end
  end

  def [](key)
    @data[key.to_sym]
  end

  def country_code
    @data[:country_code]
  end

  def country_code=(value)
    iso = ISO3166::Country.new(value)
    raise InvalidAddressError.new(:country, value) unless iso
    @data[:country_code] = value
    name = iso.name
    result = name.match /(Taiwan)/
    name = result[1] if result
    @data[:country] = I18n.t("country.#{name.gsub(/\s+/, '')}", default: name)
  end

  def province_id
    @data[:province_id]
  end

  def province_id=(value)
    @data[:province_id] = value
    @data[:province] = Province.find_by_id(value).try(:name)
  end

  def dist_code
    @data[:dist_code]
  end

  def dist_code=(value)
    return if value.blank?
    case value.to_s.length
    when 3
      district = DomainData::Taiwan::District[value]
      raise InvalidAddressError.new(:dist, value) unless district
      @data[:dist] = district.name
      @data[:city] = district.city.name
    when 6
      district = DomainData::China::District[value]
      raise InvalidAddressError.new(:dist, value) unless district
      @data[:dist] = district.name
      @data[:city] = district.city.name
      @data[:city_code] = district.city.code
      @data[:province] = district.city.province.name
      @data[:province_code] = district.city.province.code
      @data[:province_id] = district.city.province.id
    else
      raise InvalidAddressError.new(:dist, value) unless district
    end

    @data[:dist_code] = value
  end

  FIELDS.each do |name|
    class_eval <<-RUBY
      def #{name}
        @data[:#{name}]
      end

      def #{name}=(value)
        @data[:#{name}] = value
      end
    RUBY
  end

  alias_method :postal_code, :zip_code
  alias_method :postal_code=, :zip_code=

  def to_s
    case country_code
    when 'TW'
      @data.values_at(:country, :city, :dist, :address, :zip_code).reject(&:blank?).compact.join
    when 'CN'
      @data.values_at(:country, :province, :city, :dist, :address, :zip_code).reject(&:blank?).compact.join
    else
      @data.values_at(:address, :dist, :city, :state, :zip_code, :country).reject(&:blank?).compact.join(', ')
    end
  end

  alias_method :full_address, :to_s

  def administrative_areas
    [state, province, city, dist].reject(&:blank?)
  end

  def to_h
    @data.stringify_keys
  end
end
