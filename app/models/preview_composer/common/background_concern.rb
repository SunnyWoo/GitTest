module PreviewComposer::Common::BackgroundConcern
  extend ActiveSupport::Concern

  included do
    store_accessor :layers, %w(background_width background_height background_filename)
    attr_reader :background_file
    validate :attrs_presence
    after_save :upload_background_file
  end

  def background
    PreviewComposer::Common::Background.new(width: background_width,
                                            height: background_height,
                                            composer: self,
                                            filename: background_filename,
                                            file: background_file)
  end

  def background_file=(background_file)
    @background_file = background_file
    self.background_filename = background_file.original_filename
  end

  def upload_background_file
    return unless background_file
    background.upload_file
    @background_file = nil
  end

  private

  # 他们不能同时为空
  def attrs_presence
    return if background_file.present? || (background_width.present? && background_height.present?)
    errors.add(:base, "file or (width and height) cant't be blank")
  end
end
