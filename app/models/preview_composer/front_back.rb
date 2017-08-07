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

class PreviewComposer::FrontBack < PreviewComposer
  store :layers, coder: JSON

  def self.available_params
    %w(background_width background_height background_file case_file
       left_mask_file left_mask_left left_mask_top left_mask_width left_mask_height
       right_mask_file right_mask_left right_mask_top right_mask_width right_mask_height)
  end

  include PreviewComposer::Common::BackgroundConcern

  concerning :CaseConcern do
    included do
      store_accessor :layers, %w(case_filename)
      attr_reader :case_file
      validates :case_file, presence: true
      after_save :upload_case_file
    end

    def case
      Case.new(composer: self, filename: case_filename, file: case_file)
    end

    def case_file=(case_file)
      @case_file = case_file
      self.case_filename = case_file.original_filename
    end

    def upload_case_file
      return unless case_file
      self.case.upload_file
      @case_file = nil
    end
  end

  concerning :LeftMaskConcern do
    included do
      store_accessor :layers, %w(left_mask_filename
                                 left_mask_left left_mask_top
                                 left_mask_width left_mask_height)
      attr_reader :left_mask_file
      validates :left_mask_file, presence: true
      after_save :upload_left_mask_file
    end

    def left_mask
      LeftMask.new(composer: self,
                   filename: left_mask_filename, file: left_mask_file,
                   left: left_mask_left, top: left_mask_top,
                   width: left_mask_width, height: left_mask_height)
    end

    def left_mask_file=(left_mask_file)
      @left_mask_file = left_mask_file
      self.left_mask_filename = left_mask_file.original_filename
    end

    def upload_left_mask_file
      return unless left_mask_file
      left_mask.upload_file
      @left_mask_file = nil
    end
  end

  concerning :RightMaskConcern do
    included do
      store_accessor :layers, %w(right_mask_filename
                                 right_mask_left right_mask_top
                                 right_mask_width right_mask_height)
      attr_reader :right_mask_file
      validates :right_mask_file, presence: true
      after_save :upload_right_mask_file
    end

    def right_mask
      RightMask.new(composer: self,
                    filename: right_mask_filename, file: right_mask_file,
                    left: right_mask_left, top: right_mask_top,
                    width: right_mask_width, height: right_mask_height)
    end

    def right_mask_file=(right_mask_file)
      @right_mask_file = right_mask_file
      self.right_mask_filename = right_mask_file.original_filename
    end

    def upload_right_mask_file
      return unless right_mask_file
      right_mask.upload_file
      @right_mask_file = nil
    end
  end

  concerning :BuildOrderImage do
    include ImageService::MiniMagick::ImageFactory

    def build_order_image(cover)
      return unless cover.url

      Rails.logger.debug "Building order image with #{self.class.name}..."
      tempfile = Tempfile.new(['order_image', '.png'])
      # 外殼
      Rails.logger.debug 'Loading case image...'
      case_image = open_image(self.case.uploader.escaped_url)
      # 左半部遮罩
      Rails.logger.debug 'Loading case left mask image...'
      case_left_mask = create_mask_image(left_mask.uploader.escaped_url)
      # 右半部遮罩
      Rails.logger.debug 'Loading case right mask image...'
      case_right_mask = create_mask_image(right_mask.uploader.escaped_url)
      # 底圖
      Rails.logger.debug 'Creating background image...'
      canvas = if background.uploader.present?
                 open_image(background.uploader.escaped_url)
               else
                 create_blank_image(background.width, background.height)
               end
      # 作品
      Rails.logger.debug 'Loading print image...'
      cover = open_image(cover.escaped_url)
      # 左邊
      Rails.logger.debug 'Drawing left cover...'
      cover.resize size_from_dimension(left_mask.dimension)
      canvas = canvas.composite(cover, '.png', case_left_mask) do |c|
        c.geometry position_from_dimension(left_mask.dimension)
      end
      # 右邊
      Rails.logger.debug 'Drawing right cover...'
      cover.resize size_from_dimension(right_mask.dimension)
      canvas = canvas.composite(cover, '.png', case_right_mask) do |c|
        c.geometry position_from_dimension(right_mask.dimension)
      end
      # 外殼
      Rails.logger.debug 'Drawing case...'
      canvas = canvas.composite(case_image)
      # 寫入並傳回暫時檔案
      Rails.logger.debug 'Exporting...'
      canvas.write(tempfile.path)
      tempfile
    end

    def open_image(url)
      ::MiniMagick::Image.open(url)
    end

    def create_mask_image(url)
      mask = open_image(url)
      mask.background 'black'
      mask.flatten
      mask
    end

    def size_from_dimension(dimension)
      '%dx%d!' % [dimension[2].to_i, dimension[3].to_i]
    end

    def position_from_dimension(dimension)
      "%+d%+d" % [dimension[0].to_i, dimension[1].to_i]
    end
  end
end
