class Store::TextSettingsForm
  include ActiveModel::Model

  def initialize(attributes = {})
    ProductTemplate::TEXT_SETTING_KEYS.each do |key|
      self.class.send(:attr_accessor, key)
    end
    super(attributes)
  end

  def self.model_name
    ActiveModel::Name.new(self.class, nil, 'settings')
  end
end
