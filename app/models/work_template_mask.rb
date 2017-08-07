class WorkTemplateMask
  include ActiveModel::Model

  attr_accessor :material_name, :scale_x, :scale_y, :position_x,
                :position_y, :orientation

  validates :material_name, presence: true

  def self.dump(object)
    object.as_json
  end

  def self.load(hash)
    WorkTemplateMask.new(hash) if hash
  end

  module ArraySerializer
    def self.dump(object)
      object.as_json
    end

    def self.load(array_of_hash)
      array_of_hash.map { |hash| WorkTemplateMask.new(hash) } if array_of_hash
    end
  end
end
