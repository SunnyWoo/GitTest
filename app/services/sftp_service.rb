require 'net/sftp'

class SftpService
  include FtpLogcraft

  def initialize(args = {})
    @default_upload_path = "ftp/#{Time.now.strftime("%Y%m%d")}"
    @url = args.delete(:url)
    @username = args.delete(:username)
    @password = args.delete(:password)
  end

  def ftp
    @ftp ||= Net::SFTP.start(@url, @username, password: @password)
  end

  def upload_file(file_name, remote_path, args = {})
    begin
      mkdir_p(File.dirname(remote_path))
      memo = args.delete(:memo)
      tmp_file = File.new(file_name)
      start_at = Time.now.to_f
      logcraft(:begin_upload,
               "memo:#{memo}",
               file: remote_path,
               file_size: tmp_file.size
              )
      ftp.upload!(file_name, remote_path)
      end_at = Time.now.to_f
      logcraft(:end_upload,
               "memo:#{memo}",
               file: remote_path,
               upload_time: (end_at - start_at).round(2)
              )
    rescue => e
      e.to_s
    end
  end

  def mkdir_p(path)
    path.split('/').inject([]) do |parts, part|
      parts << part
      p = parts.join('/')
      begin
        ftp.mkdir!(p) unless p.blank?
      rescue Net::SFTP::StatusException
        Rails.logger.info "mkdir_p: #{path} is already exists."
      end
      parts
    end
  end

  def close
    @ftp.close_channel
    logcraft(:close, "SFTP Host: #{@url}")
  end
end
