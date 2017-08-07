class EmailUnconfirmedError < ApplicationError
  def message
    'email need confirmed'
  end
end
