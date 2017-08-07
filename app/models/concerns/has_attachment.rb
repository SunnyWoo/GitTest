# Usage:
#
#     has_attachment :image
#
# Then you got these:
#
#     model.image_aid = 'blah...'
#     model.valid? # loads attachment to model.image by aid
module HasAttachment
  extend ActiveSupport::Concern

  included do
    before_validation :assign_attachment_to_columns
    after_save :clear_attachments
  end

  def attachments
    @attachments ||= {}
  end

  def assign_attachment_to_columns
    attachments.each do |column, aid|
      next unless aid
      attachment = Attachment.find_by_aid!(aid)
      send("#{column}=", attachment.file)
    end
  end

  def clear_attachments
    @attachments = {}
  end

  module ClassMethods
    def has_attachment(column)
      define_method "#{column}_aid=" do |aid|
        attachments[column] = aid
      end
    end
  end
end
