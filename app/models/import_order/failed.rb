class ImportOrder::Failed
  include ActiveModel::Model
  attr_accessor :platform_code, :message

  def self.dump(object)
    object.as_json
  end

  def self.load(hash)
    ImportOrder::Failed.new(hash) if hash
  end

  module ArraySerializer
    def self.dump(object)
      object.as_json
    end

    def self.load(array_of_hash)
      return array_of_hash.map { |hash| ImportOrder::Failed.new(hash) } if array_of_hash
      []
    end
  end
end
