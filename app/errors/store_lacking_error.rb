class StoreLackingError < ApplicationError
  def message
    '储备不足'
  end
end
