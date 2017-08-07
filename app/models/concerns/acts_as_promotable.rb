module ActsAsPromotable
  extend ActiveSupport::Concern

  included do
    has_many :promotion_references, as: :promotable, dependent: :destroy
    has_many :promotions, through: :promotion_references
  end
end
