class PrintItem::CodeHandler
  class << self
    def encode(timestamp_no)
      return nil if timestamp_no.blank?
      short_year = timestamp_no.to_s[2..3]
      head = "C#{short_year}"
      body = timestamp_no.to_s[4, timestamp_no.size]
      body = body.to_i.to_s(32).rjust(5, '0').upcase
      [head, body].join('-')
    end

    def decode(code)
      code_info = code.to_s.split('-')
      return code if code_info.size != 2
      year = "20#{code_info[0][1, 2]}"
      [year, code_info.last.to_i(32)].join('')
    end
  end
end
