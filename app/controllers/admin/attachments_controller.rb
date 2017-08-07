class Admin::AttachmentsController < ApplicationController
  def create
    @attachment = Attachment.create(params.permit(:file, :remote_file_url))
    render 'api/v3/attachments/show'
  end
end
