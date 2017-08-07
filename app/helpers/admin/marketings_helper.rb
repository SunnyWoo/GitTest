module Admin::MarketingsHelper
  def render_send_sms_status(extra_info)
    text = "成功数量: #{extra_info['success_amount'].to_i};失败数量:#{extra_info['fail_amount'].to_i}"
    if extra_info['error_message'].present?
      text += ";错误信息:#{extra_info['error_message']}"
    end
    text
  end
end
