class Report::OrderSticker::DataInfo
  class << self
    def dump(object)
      object.as_json
    end

    def load(hash)
      new(hash) if hash
    end

    def extract_from_order_items(items)
      items.each_with_object({}) do |item, result|
        work = item.itemable
        next if [StandardizedWork, ArchivedStandardizedWork].include?(work.class)
        work.layers.each do |layer|
          next unless Layer::STICKER_TYPES.include?(layer.layer_type)
          result[layer.layer_type] ||= {}
          result[layer.layer_type][work.product.key] ||= 0
          result[layer.layer_type][work.product.key] += item.quantity
        end
      end
    end
  end

  include Enumerable
  delegate :each, :size, to: :rows

  attr_reader :original_content

  delegate :as_json, to: :original_content

  def initialize(hash)
    @original_content = hash.dup
    normalize_data(hash)
  end

  def rows
    @rows ||= []
  end

  def transpose
    convert_hash_to_rows(transpose_to_hash)
  end

  def transpose!
    @rows = transpose
  end

  private

  def default_data
    Layer::STICKER_TYPES.each_with_object({}) do |sticker_type, result|
      result[sticker_type] = {}
      ProductCategory::AVAILABLE_MODEL_KEYS.each do |model_key|
        result[sticker_type][model_key] = 0
      end
    end
  end

  def normalize_data(data)
    data = default_data.deep_merge(data)
    convert_hash_to_rows(data, rows)
  end

  def row_class
    RowNumber
  end

  def as_matrix
    rows.map(&:hash).map(&:values)
  end

  def to_matrix
    Matrix[*as_matrix]
  end

  def transpose_to_hash
    sub_keys = rows.map(&:key)
    keys = rows.first.hash.keys
    matrix = to_matrix
    hash = {}
    new_matrix_data = matrix.transpose.to_a
    keys.each_with_index do |key, key_index|
      hash[key] = {}
      sub_keys.each_with_index do |sub_key, sub_key_index|
        hash[key][sub_key] = new_matrix_data[key_index][sub_key_index]
      end
    end
    hash
  end

  def convert_hash_to_rows(hash, container = [])
    hash.each_with_object(container) do |hash_to_array, result|
      result << row_class.new(*hash_to_array)
    end
  end
end
