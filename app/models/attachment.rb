# == Schema Information
#
# Table name: attachments
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  file_meta  :json
#  created_at :datetime
#  updated_at :datetime
#

class Attachment < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord

  serialize :file_meta, Hashie::Mash.pg_json_serializer

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  carrierwave_meta_composed :file_meta, :file, image_version: [:content_type, :size, :width, :height, :md5sum]
  # before_save :check_file_meta, if: :file_changed?

  def self.find_by_aid(aid)
    GlobalID::Locator.locate_signed(aid, for: 'assignment')
  end

  def self.find_by_aid!(aid)
    find_by_aid(aid) or fail(RecordNotFoundError)
  end

  def aid
    to_sgid(for: 'assignment').to_s
  end

  def remote_file_url=(url)
    data_url = split_base64(url)
    if data_url
      self.file = data_url_to_file(data_url)
    else
      super
    end
  end

  delegate :meta, :name, :content_type, :size, :md5sum, :width, :height, to: :file

  private

  # modified from http://www.davehulihan.com/uploading-data-uris-in-carrierwave/
  def split_base64(url_str)
    match = url_str.match(/^data:(.*?);(.*?),(.*)$/)
    return unless match
    {
      type: match[1], # "image/gif"
      encoder: match[2], # "base64"
      data: match[3], # data string
      extension: match[1].split('/')[1] # "gif"
    }
  end

  def data_url_to_file(url)
    data_binary = Base64.decode64(url[:data])
    filename = Digest::MD5.hexdigest(data_binary)
    temp_file = Tempfile.new(filename)
    temp_file.binmode
    temp_file << data_binary
    temp_file.rewind

    params = {
      filename: "#{filename}.#{url[:extension]}",
      type: url[:type],
      tempfile: temp_file
    }
    ActionDispatch::Http::UploadedFile.new(params)
  end

  def check_file_meta
    return unless file.present?
    file.store!(file.file)
    file.store_meta(md5sum: true)
  end
end
