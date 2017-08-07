# push = Getui::PushSingleMessage.new(
#   text: 'String',
#   title: 'String',
#   client_id: 'String'
# )
#
# push.execute
#
class Getui::PushSingleMessage < GetuiService
  attr_accessor :text, :title, :client_id

  def initialize(args = {})
    super
    @title = args.delete(:title)
    @text = args.delete(:text)
    @client_id = args.delete(:client_id)
  end

  # return example
  #    {
  #      "taskId" => "OSS-0803_pDKsoDFtXZ67OP2lzimeQ3",
  #      "result" => "ok",
  #      "status" => "successed_online"
  #    }
  def execute
    raise InvalidError.new(caused_by: 'Title') if @title.nil?
    raise InvalidError.new(caused_by: 'client_id') if @client_id.nil?

    template = IGeTui::NotificationTemplate.new
    template.title = @title
    template.text = @text

    single_message = IGeTui::SingleMessage.new
    single_message.data = template
    client = IGeTui::Client.new(@client_id)
    begin
      @pusher.push_message_to_single(single_message, client)
    rescue => e
      return e
    end
  end
end
