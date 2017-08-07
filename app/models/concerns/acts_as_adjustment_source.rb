module ActsAsAdjustmentSource
  extend ActiveSupport::Concern

  included do
    has_many :adjustments, as: :source
  end

  def source_name
    fail 'Not yet implemented!'
  end
end
