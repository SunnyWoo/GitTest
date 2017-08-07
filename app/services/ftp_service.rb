require 'net/ftp'

class FtpService
  include FtpLogcraft

  def initialize(args = {})
    @default_upload_path = "ftp/#{Time.now.strftime("%Y%m%d")}"
    @url = args.delete(:url)
    @port = args.delete(:port)
    @username = args.delete(:username)
    @password = args.delete(:password)
  end

  def login
    begin
      @ftp = Net::FTP.new(@url)
      @ftp.passive = true
      @ftp.connect(@url, @port)
      @ftp.login(@username, @password)
      logcraft(:login, "FTP login success Host: #{@url}:#{@port}")
      true
    rescue => e
      logcraft(:login, "FTP login Host: #{@url}:#{@port} error: #{e}")
      false
    end
  end

  def status
    begin
      @ftp.status.to_i
    rescue
      0
    end
  end

  def close
    @ftp.close
    logcraft(:close, "Host: #{@url}:#{@port}")
  end

  def chdir(path = nil)
    path = @default_upload_path if path.nil?
    begin
      @ftp.chdir(path)
      logcraft(:chdir, "chdir:#{path}")
    rescue => e
      logcraft(:chdir_error, "chdir:#{path} error:#{e}")
      if e.to_s.match("No such file or directory")
        mkdir(path)
        chdir(path)
      end
    end
  end

  def mkdir(path = nil)
    path = @default_upload_path if path.nil?
    begin
      parts = path.split("/")
      if parts.first == "~"
        growing_path = ""
      else
        growing_path = "/"
      end
      for part in parts
        next if part == ""
        if growing_path == ""
          growing_path = part
        else
          growing_path = File.join(growing_path, part)
        end
        begin
          @ftp.mkdir(growing_path)
        rescue Net::FTPPermError, Net::FTPTempError => e
          logcraft(:mkdir_error, "mkdir:#{path} error:#{e}")
        end
      end
      logcraft(:mkdir, "mkdir:#{path}")
    rescue => e
      logcraft(:mkdir_error, "mkdir:#{path} error:#{e}")
    end
  end

  def mkdir_p(path)
    path.split('/').inject([]) do |parts, part|
      parts << part
      path = parts.join('/')
      begin
        @ftp.mkdir(path)
      rescue Net::FTPPermError
        Rails.logger.info "mkdir_p: #{path} is already exists."
      end
      parts
    end
  end

  # 單檔上傳
  def upload_file(file_name, args = {})
    begin
      memo = args.delete(:memo)
      tmp_file = File.new(file_name)
      start_at = Time.now.to_f
      logcraft(:begin_upload,
        "memo:#{memo}",
        file: "#{@ftp.pwd()}/#{file_name}",
        file_size: tmp_file.size,
        )
      @ftp.putbinaryfile(tmp_file, args[:filename] || File.basename(tmp_file))
      end_at = Time.now.to_f
      logcraft(:end_upload,
        "memo:#{memo}",
        file: "#{@ftp.pwd()}/#{file_name}",
        upload_time: (end_at - start_at).round(2),
        )
      File.delete(file_name)
    rescue => e
      e.to_s
    end
  end

  def check_server
    status = 0
    begin
      status = @ftp.last_response_code.to_i
    end
  end
end
