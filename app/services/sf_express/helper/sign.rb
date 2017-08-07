module SfExpress::Helper::Sign
  # 校验码的生成
  def verify_code(xml_str)
    md5_str = Digest::MD5.digest(xml_str + Settings.sf_express.checkword)
    Base64.encode64(md5_str)
  end
end
