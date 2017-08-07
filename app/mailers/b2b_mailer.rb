class B2bMailer < ApplicationMailer
  layout false

  def stickers(email, file_path)
    attachments[File.basename(file_path)] = File.read(file_path)
    mail to: email, subject: 'B2B 贴纸' do |format|
      format.text { render text: '请下载附件' }
    end
  end
end
