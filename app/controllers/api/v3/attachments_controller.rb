class Api::V3::AttachmentsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {post} /api/attachments Create Attachment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Attachments
@apiName CreateAttachment
@apiParam {File} file must be a multipart request
@apiParam {String} remote_file_url url, ex: `http://commandp.dev`
@apiParamExample {json} Request-Example:
  {
    "file": "(must be a multipart request)",
    "remote_file_url": "http://commandp.dev/media/W1siZiIsIj....jpg",
  }
@apiSuccessExample {json} Response-Example:
 {
    "attachment": {
      "id": "BAh7CEkiCGdpZAY6BkVUS...",
      "url": "http://commandp.dev/media/W1siZiIsIj....jpg",
      "format": 'jpeg',
      "size": 411263,
      "md5sum": "53bb6412d602060eeb48ea43a46ade3b",
      "width": 1654,
      "height": 1654
    }
  }
=end
  def create
    @attachment = Attachment.create!(params.permit(:file, :remote_file_url))
    render 'api/v3/attachments/show'
  end

=begin
@api {get} /api/attachments/:id Get Attachment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Attachments
@apiName GetAttachment
@apiParam {Integer} id the file id
@apiSuccessExample {json} Response-Example:
 {
    "attachment": {
      "id": "BAh7CEkiCGdpZAY6BkVUS...",
      "url": "http://commandp.dev/media/W1siZiIsIj....jpg",
      "format": 'jpeg',
      "size": 411263,
      "md5sum": "53bb6412d602060eeb48ea43a46ade3b",
      "width": 1654,
      "height": 1654
    }
  }
=end
  def show
    @attachment = Attachment.find_by_aid!(params[:id])
  end
end
