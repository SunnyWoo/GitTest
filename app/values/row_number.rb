class RowNumber
  include Enumerable
  delegate :each, :size, to: :values

  attr_reader :key, :hash, :values

  alias_method :length, :size

  def initialize(key = nil, hash = {})
    @key = key
    @hash = hash.with_indifferent_access
    @values = hash.values.map(&:to_f)
  end

  def sum
    @sum ||= values.reduce(:+).to_f
  end

  def mean
    @mean ||= (sum / size).round(4)
  end

  def variance
    @variance or begin
      @variance = values.reduce(0) do |result, x|
        result + (x - mean)**2
      end./(size).round(4)
    end
  end

  def medium
    pos = (length.to_f / 100 * 50)
    if pos % 1 == 0
      (values.sort[pos - 1] + values.sort[pos]) / 2
    else
      values.sort[pos.floor]
    end
  end

  def mode
    result = values.each_with_object({}) do |value, hash|
      if hash.keys.include? value
        hash[value] += 1
      else
        hash[value] = 1
      end
    end
    last_two = result.sort_by { |_key, value| value }.last(2)
    # 眾數不一定存在，若存在必唯一
    last_two.to_h.values.reduce(:-) == 0 ? nil : last_two.last.first
  end

  def standard_dev
    Math.sqrt(variance).round(4)
  end

  def range
    values.sort.last - values.sort.first
  end

  def where(component: [])
    component = Array(component) unless component.is_a? Array
    return self if ['all', :all].any? { |value| component.include? value }
    self.class.new('subset', hash.slice(*component))
  end

  def ==(other)
    hash == other.try(:hash)
  end
end
