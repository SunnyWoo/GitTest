class ProductModel::Positions
  include Virtus.model

  attribute :ios,     Integer
  attribute :android, Integer
  attribute :website, Integer

  def self.dump(extra_info)
    extra_info.as_json
  end

  def self.load(hash)
    new(hash)
  end
end
