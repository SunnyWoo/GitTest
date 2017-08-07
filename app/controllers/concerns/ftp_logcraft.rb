module FtpLogcraft
  def logcraft(key, message = nil, extra_info = {})
    Logcraft::Activity.create(trackable_type: 'FtpService',
                              source: {channel: 'ftp'},
                              key: key,
                              message: message,
                              extra_info: extra_info)
  end
end
