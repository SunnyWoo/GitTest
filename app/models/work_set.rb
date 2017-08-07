# == Schema Information
#
# Table name: work_sets
#
#  id                  :integer          not null, primary key
#  designer_id         :integer
#  model_id            :integer
#  work_ids            :integer          default([]), is an Array
#  created_at          :datetime
#  updated_at          :datetime
#  zip_filename        :string(255)
#  zip_entry_filenames :string(255)      default([]), is an Array
#  designer_type       :string(255)
#

class WorkSet < ActiveRecord::Base
  PREVIEW_PATH_PATTERN = %r{([^/]+)/previews/(.+)\.}
  OUTPUT_FILE_PATH_PATTERN = %r{([^/]+)/output-files/(.+)\.}
  STANDALONE_PATH_PATTERN = %r{([^/]+)\.}

  attr_accessor :zip, :build_previews, :is_build_print_image, :aasm_state

  belongs_to :designer, polymorphic: true
  belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id

  validates :designer, presence: true
  validate :validate_zip_entries_size

  before_validation :extract_zip_entries
  before_save :create_works_by_zip_entries
  after_save :clear_zip_entries

  delegate :name, to: :product, prefix: true

  scope :non_store, -> { where.not(designer_type: 'Store') }

  def works
    StandardizedWork.where(id: work_ids)
  end

  def works=(works)
    self.work_ids = works.map(&:id)
  end

  def zip_entries
    @zip_entries ||= []
  end

  def works_attributes
    @works_attributes ||= zip_entries.each_with_object({}) do |entry, works_attributes|
      case entry[:path]
      when PREVIEW_PATH_PATTERN
        add_preview_to_works_attributes(entry, works_attributes)
      when OUTPUT_FILE_PATH_PATTERN
        add_output_file_to_works_attributes(entry, works_attributes)
      when STANDALONE_PATH_PATTERN
        add_standalong_path_to_works_attributes(entry, works_attributes)
      end
    end
  end

  private

  def extract_zip_entries
    return if zip.nil?

    self.zip_filename = File.basename(zip.original_filename)
    zip_entry_filenames_will_change!
    zip_extractor = ZipExtractor.new(zip, /^(?!__MACOSX).*\.(jpe?g|png|gif|ai|pdf)/)
    zip_entries.concat(zip_extractor.extract_zip_entries)
    self.zip_entry_filenames = zip_entries.map { |entry| entry[:path] }
  rescue Zip::Error => e
    errors.add(:zip, e.message)
  end

  def validate_zip_entries_size
    return if zip_entries.empty?

    width = product.dpi_width.round
    height = product.dpi_height.round

    works_attributes.each do |name, work_attributes|
      work_attributes[:output_files_attributes].each do |output_file_attributes|
        next unless output_file_attributes[:file].path =~ /\.(jpe?g|png|gif)/
        image = MiniMagick::Image.open(output_file_attributes[:file].path)
        next if image[:width] == width && image[:height] == height
        errors.add(:zip, "The size of #{name}/#{output_file_attributes[:key]} "\
                         "(#{image[:width]}x#{image[:height]})" \
                         " is not fit selected product (#{width}x#{height})")
      end
    end
  end

  def create_works_by_zip_entries
    self.works = works_attributes.map do |_name, work_attributes|
      sw = StandardizedWork.create!(work_attributes.merge(build_previews: build_previews,
                                                          is_build_print_image: is_build_print_image,
                                                          aasm_state: aasm_state))
      sw.previews.find_by(key: 'order-image').move_to_top if sw.order_image
      sw.output_files.map(&:touch)
      sw
    end
  end

  def add_preview_to_works_attributes(entry, works_attributes)
    m = PREVIEW_PATH_PATTERN.match(entry[:path])
    name = m[1]
    key = m[2]
    works_attributes[name] ||= new_works_attributes(name: name)
    works_attributes[name][:previews_attributes] << { key: key, image: entry[:file] }
  end

  def add_output_file_to_works_attributes(entry, works_attributes)
    m = OUTPUT_FILE_PATH_PATTERN.match(entry[:path])
    name = m[1]
    key = m[2]
    works_attributes[name] ||= new_works_attributes(name: name)
    works_attributes[name][:output_files_attributes] << { key: key, file: entry[:file] }
  end

  def add_standalong_path_to_works_attributes(entry, works_attributes)
    m = STANDALONE_PATH_PATTERN.match(entry[:path])
    name = m[1]
    works_attributes[name] ||= new_works_attributes(name: name)
    works_attributes[name][:output_files_attributes] << { key: 'print-image', file: entry[:file] }
  end

  def new_works_attributes(attributes)
    { user: designer, product: product, previews_attributes: [], output_files_attributes: [] }.merge(attributes)
  end

  def clear_zip_entries
    @zip = nil
    @zip_entries = []
    @works_attributes = nil
  end
end
