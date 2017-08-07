class PreviewComposer::FrontBack::RightMask
  include ActiveModel::Model

  attr_accessor :composer, :filename, :file, :left, :top, :width, :height

  def initialize(*)
    super
    uploader.retrieve_from_store!(filename) if filename
  end

  def upload_file
    uploader.store!(file)
  end

  def uploader
    @uploader ||= ComposerUploader.new(composer, 'right_mask')
  end

  def dimension
    [left, top, width, height]
  end
end
