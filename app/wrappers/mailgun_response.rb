class MailgunResponse
  def initialize(params)
    @params = params
  end

  def subject
    #因為message-headers吐回來的key值是數字..
    message_header[5][1] if message_header
  end

  def recipient
    @params[:recipient]
  end

  def order_no
    @params[:order_no]
  end

  def bounced_message
    @params[:error]
  end

  def dropped_message
    @params[:description]
  end

  def event
    @params[:event]
  end

  def message_header
    JSON.parse(@params[:'message-headers']) if @params[:'message-headers']
  end

  def signature
    @params[:signature]
  end

  def timestamp
    @params[:timestamp]
  end

  def token
    @params[:token]
  end
end
