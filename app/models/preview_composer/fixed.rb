# == Schema Information
#
# Table name: preview_composers
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  model_id    :integer
#  layers      :text
#  created_at  :datetime
#  updated_at  :datetime
#  key         :string(255)
#  available   :boolean          default(FALSE), not null
#  position    :integer
#  template_id :integer
#

class PreviewComposer::Fixed < PreviewComposer
  store :layers, coder: JSON

  def self.available_params
    %w(background_width image_file)
  end

  concerning :ImageConcern do
    included do
      store_accessor :layers, %w(image_filename)
      attr_reader :image_file
      validates :image_file, presence: true
      after_save :upload_image_file
    end

    def image
      Image.new(composer: self, filename: image_filename, file: image_file)
    end

    def image_file=(image_file)
      @image_file = image_file
      self.image_filename = image_file.original_filename
    end

    def upload_image_file
      return unless image_file
      image.upload_file
      @image_file = nil
    end
  end

  concerning :BuildOrderImage do
    include ImageService::MiniMagick::ImageFactory

    def build_order_image(_cover)
      File.open(open_image(image.uploader.escaped_url).path)
    end

    def open_image(url)
      ::MiniMagick::Image.open(url)
    end
  end
end
