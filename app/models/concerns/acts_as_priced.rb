module ActsAsPriced
  extend ActiveSupport::Concern

  included do
    has_many :change_price_histories, as: :changeable
  end
end
