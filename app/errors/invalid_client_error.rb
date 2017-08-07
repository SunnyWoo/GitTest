class InvalidClientError < ApplicationError
  def message
    I18n.t(:invalid_client, scope: 'errors')
  end

  def status
    :unauthorized
  end
end
