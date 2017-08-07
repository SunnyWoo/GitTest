class BetterFtpService
  include FtpLogcraft
  attr_reader :host, :port, :username, :password, :ftp

  def initialize(args = {})
    @host     = args.delete(:host)
    @port     = args.delete(:port)
    @username = args.delete(:username)
    @password = args.delete(:password)
  end

  def login
    @ftp = Net::FTP.new(host)
    ftp.passive = true
    ftp.connect(host, port)
    ftp.login(username, password)

    logcraft(:login, "FTP login success. Host: #{@url}:#{@port}")
  rescue Net::FTPPermError => e
    logcraft(:login, "FTP login fail. Host: #{@url}:#{@port}, error: #{e.message}")
    raise
  end

  def mkdir_p(path)
    path.split('/').inject([]) do |parts, part|
      begin
        parts << part
        path = parts.join('/')
        ftp.mkdir(path)
      rescue Net::FTPPermError
        Rails.logger.warn "Couldn't mkdir #{parts}."
      end
      parts
    end
  end

  def chdir(path)
    ftp.chdir(path)
  rescue Net::FTPPermError
    mkdir_p(path)
    ftp.chdir(path)
  end

  def upload_file(file, filename: File.basename(file))
    file = File.open(file) unless file.is_a?(File)
    start_at = Time.now.to_f
    logcraft(:begin_upload, nil, file: file.path, file_size: file.size)
    ftp.putbinaryfile(file, filename)
    end_at = Time.now.to_f
    logcraft(:end_upload, nil, file: file.path, upload_time: (end_at - start_at).round(2))
  end

  def close
    return nil unless ftp
    ftp.close
    @ftp = nil
    logcraft(:close, "Host: #{@url}:#{@port}")
  end
end
