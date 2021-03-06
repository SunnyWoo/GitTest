class PreviewComposer::Fixed::Image
  include ActiveModel::Model

  attr_accessor :composer, :filename, :file

  def initialize(*)
    super
    uploader.retrieve_from_store!(filename) if filename
  end

  def upload_file
    uploader.store!(file)
  end

  def uploader
    @uploader ||= ComposerUploader.new(composer, 'image')
  end
end
