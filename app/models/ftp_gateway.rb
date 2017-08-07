# == Schema Information
#
# Table name: file_gateways
#
#  id           :integer          not null, primary key
#  type         :string(255)
#  factory_id   :integer
#  connect_info :hstore
#  created_at   :datetime
#  updated_at   :datetime
#

class FtpGateway < FileGateway
  store_accessor :connect_info, :url , :port, :username, :password, :enable_sftp
  before_save :encode_password

  def check_server
    last_response_code = 0
    connection_with_timeout do |ftp|
      last_response_code = ftp.check_server
      create_activity(:check_server, user: factory, message: "FTP check_server response_code: #{last_response_code}")
    end
    last_response_code.to_i
  end

  def status
    status = 0
    connection do |ftp|
      status = ftp.status
      create_activity(:check_ststus, user: factory, message: "FTP status: #{status}")
    end
    status
  end

  def upload(file, path: nil, filename: File.basename(file))
    return sftp_upload(file, path: path, filename: filename) if enable_sftp.to_b
    connect do |ftp|
      if path
        FileUtils::mkdir_p(path) unless Dir.exist?(path)
        ftp.chdir(path)
      end
      ftp.upload_file(file, filename: filename)
    end
  end

  def sftp_upload(file, path: nil, filename: File.basename(file))
    @serv ||= SftpService.new(url: url, username: username,
                           password: Base64.decode64(password))
    path = "/#{path}" unless path.start_with?('/')
    path.gsub!(/\/$/, '')
    @serv.upload_file(file, "#{path}/#{filename}")
  end

  def batch_upload(file_names, path = nil, args = {})
    status = false
    connection do |ftp|
      ftp.chdir(path)
      file_names.each do |file_name|
        ftp.upload_file(file_name, args)
      end
      status = true
    end
    status
  end

  def connect
    ftp = BetterFtpService.new(host: url,
                               port: port,
                               username: username,
                               password: Base64.decode64(password))
    begin
      ftp.login
      yield ftp
    ensure
      ftp.close
    end
  end

  private

  def connection
    ftp = FtpService.new(url: url,
                         port: port,
                         username: username,
                         password: Base64.decode64(password))
    begin
      login_status = ftp.login
      return false if login_status == false
      yield ftp
    rescue
      false
    ensure
      ftp.close
    end
  end

  def connection_with_timeout(sec = 10)
    ftp = FtpService.new(url: url,
                         port: port,
                         username: username,
                         password: Base64.decode64(password))
    begin
      Timeout.timeout sec do
        login_status = ftp.login
        return false if login_status == false
        yield ftp
      end
    rescue
      false
    rescue
      ftp.close
    end
  end

  def encode_password
    self.password = Base64.encode64(password) if password.present?
  end
end
