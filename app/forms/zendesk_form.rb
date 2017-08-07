class ZendeskForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email, :category, :subject, :description, :attachments,
                :user, :locale, :attachment_ids

  validates_presence_of :email, :category, :subject, :description
  validates :email ,format: {:with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ }

  def save!
    if valid?
      Zendesk::CreateTicketService.new(user: user).execute(attributes)
    else
      raise ActiveRecord::RecordInvalid.new self
    end
  end

  protected

  def attributes
    {
      email: email,
      category: category,
      subject: subject,
      description: description,
      attachments: attachments,
      attachment_ids: attachment_ids,
      locale: locale
    }
  end
end
