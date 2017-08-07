class DirectoryMissingError < ApplicationError
  def message
    I18n.t('errors.directory_missing', dir: caused_by)
  end

  def status
    :not_found
  end
end
