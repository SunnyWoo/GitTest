# == Schema Information
#
# Table name: work_output_files
#
#  id         :integer          not null, primary key
#  work_id    :integer
#  work_type  :string(255)
#  key        :string(255)
#  file       :string(255)
#  image_meta :json
#  created_at :datetime
#  updated_at :datetime
#

class WorkOutputFile < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord

  belongs_to :work, polymorphic: true, touch: true

  after_commit :build_white_version

  serialize :image_meta, Hashie::Mash.pg_json_serializer

  delegate :product, to: :work

  mount_uploader :file, PrintUploader
  carrierwave_meta_composed :image_meta, :file, image_version: [:width, :height, :md5sum]

  def file_aid=(aid)
    self.file = Attachment.find_by_aid!(aid).file
  end

  def archived_attributes
    { key: key, file: file }
  end

  def build_white_version
    return unless product.enable_white? && file_is_an_image?
    file.should_process = true
    file.recreate_versions!(:gray)
  end

  private

  def file_is_an_image?
    file.content_type =~ /image/
  end
end
