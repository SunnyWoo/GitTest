class Admin::TinymceAssetsController < AdminController
  skip_before_action :authenticate_admin!

  def create
    image = TinymceImage.create(params.permit(:file))

    render json: {
      image: {
        url: image.file.url
      }
    }, content_type: 'text/html'
  end
end
