class CampaignWordings
  include ActiveModel::Model

  def initialize(attributes = {})
    Campaign::WORDING_KEYS.keys.each do |key|
      self.class.send(:attr_accessor, key)
    end
    super(attributes)
  end

  def self.model_name
    ActiveModel::Name.new(self.class, nil, 'wordings')
  end
end
