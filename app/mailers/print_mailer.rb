class PrintMailer < ApplicationMailer
  layout 'mailgun_mail'

  def imposition_demo(email, imposition, attachment)
    @imposition = imposition
    @attachment = attachment
    mail to: email, subject: 'Imposition Demo'
  end

  def imposition_demo_failure(email, error)
    @error = error
    mail to: email, subject: 'Imposition Demo'
  end
end
