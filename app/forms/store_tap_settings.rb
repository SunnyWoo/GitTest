class StoreTapSettings
  include ActiveModel::Model

  attr_accessor :default, :create_name, :shop_name
  def initialize(attributes = {})
    super(attributes)
  end

  def self.model_name
    ActiveModel::Name.new(self.class, nil, 'tap_settings')
  end
end
