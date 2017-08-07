module UpcaseCode
  extend ActiveSupport::Concern

  included do
    before_validation :upcase_code
  end

  private

  def upcase_code
    code.try(:upcase!)
  end
end
