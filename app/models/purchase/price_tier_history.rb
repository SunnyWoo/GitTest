class Purchase::PriceTierHistory
  include ActiveModel::Model
  attr_accessor :count_key, :price

  def self.dump(object)
    object.as_json
  end

  def self.load(hash)
    Purchase::PriceTierHistory.new(hash) if hash
  end

  module ArraySerializer
    def self.dump(object)
      object.as_json
    end

    def self.load(array_of_hash)
      return array_of_hash.map { |hash| Purchase::PriceTierHistory.new(hash) } if array_of_hash
      []
    end
  end
end
