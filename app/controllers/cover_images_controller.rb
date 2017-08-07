class CoverImagesController < ApplicationController
  include ImageUploader

  # data: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYA..."
  def update
    @work = Work.find(params[:work_id])
    @work.update!(cover_image: uploaded_file, perform_destroy_previews: true)
    render json: @work, serializer: Webapi::PreviewsSerializer, root: false
  end
end
