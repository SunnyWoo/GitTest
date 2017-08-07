class ComposerUploader < DefaultWithMetaUploader

  def filename
    original_filename
  end
end
