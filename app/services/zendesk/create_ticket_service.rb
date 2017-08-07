require 'zendesk_api'
require 'open-uri'

class Zendesk::CreateTicketService
  attr_accessor :username, :email

  def initialize(args = {})
    @client = ZendeskAPI::Client.new do |config|
      config.url = Settings.Zendesk.url
      config.username = Settings.Zendesk.username
      config.token = Settings.Zendesk.token
      config.retry = true
      require 'logger'
      config.logger = Logger.new(STDOUT)
    end
    self.username = args[:user].try(:username) || 'Guest'
  end

  def execute(args)
    assignee_id = (args[:locale].present? && args[:locale] == 'ja') ? Settings.Zendesk.ja_agent_id : nil
    ticket = ZendeskAPI::Ticket.new(@client,
                                    requester: { name: username, email: args[:email] },
                                    subject: args[:subject],
                                    assignee_id: assignee_id,
                                    comment: { value: args[:description] },
                                    custom_fields: [
                                      { id: 22_158_785, value: args[:email] },
                                      { id: 22_158_705, value: args[:category] }
                                    ])
    if args[:attachments].present? && args[:attachments].is_a?(Array)
      args[:attachments].each do |attachment|
        ticket.comment.uploads << attachment
      end
    end
    if att_ids = args[:attachment_ids]
      dir_name = "#{Time.zone.now.to_i}#{rand(99)}"
      ticket = upload_attachments_by_ids(ticket, att_ids, dir_name) if att_ids.is_a?(Array)
    end
    if ticket.save
      FileUtils.rm_r "tmp/attachments/#{dir_name}" if File.exist? "tmp/attachments/#{dir_name}"
      return { status: true }
    else
      return { status: false, message: ticket.errors.map { |_k, v| v.map { |vv| vv['description'] } }.join }
    end
  end

  protected

  def upload_attachments_by_ids(ticket, attachment_ids, dir_name)
    attachment_ids.each do |attachment_id|
      attachment = Attachment.find_by_aid!(attachment_id)
      tmp_file = (SecureRandom.hex)[0..8]
      dir = "tmp/attachments/#{dir_name}"
      FileUtils.mkdir_p(dir) unless File.exist? dir
      File.open("#{dir}/#{tmp_file}.png", 'wb+') do |file|
        file.write open(attachment.file.url).read
      end
      ticket.comment.uploads << File.new("#{dir}/#{tmp_file}.png")
    end
    ticket
  end
end
