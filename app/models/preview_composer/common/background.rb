class PreviewComposer::Common::Background
  include ActiveModel::Model

  attr_accessor :width, :height, :composer, :filename, :file

  def initialize(*)
    super
    uploader.retrieve_from_store!(filename) if filename
  end

  def upload_file
    uploader.store!(file)
  end

  def uploader
    @uploader ||= ComposerUploader.new(composer, 'background')
  end
end
