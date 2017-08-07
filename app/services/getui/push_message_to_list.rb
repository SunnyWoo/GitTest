# push = Getui::PushMessageToList.new(
#   text: 'String',
#   title: 'String',
#   client_ids: 'Array'
# )
#
# push.execute
#
class Getui::PushMessageToList < GetuiService
  attr_accessor :text, :title, :client_ids

  def initialize(args = {})
    super
    @title = args.delete(:title)
    @text = args.delete(:text)
    @client_ids = args.delete(:client_ids)
  end

  # return example
  #   {
  #     "result" => "ok",
  #     "details" => {
  #       "112fdb5117781873febb5d8a1f28794f" => "successed_online"
  #     },
  #     "contentId" => "OSL-0803_U8fyEKRLWr6l0ILiLNfxe5"
  #   }
  def execute
    raise InvalidError.new(caused_by: 'Title') if @title.nil?
    raise InvalidError.new(caused_by: 'client_ids') if @client_ids.nil?

    template = IGeTui::NotificationTemplate.new
    template.title = @title
    template.text = @text

    list_message = IGeTui::ListMessage.new
    list_message.data = template

    client_list = []
    client_ids = @client_ids
    client_ids.each do |client_id|
      client_list << IGeTui::Client.new(client_id)
    end

    begin
      content_id = @pusher.get_content_id(list_message)
      @pusher.push_message_to_list(content_id, client_list)
    rescue => e
      return e
    end
  end
end
