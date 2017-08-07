class PreviewsController < ApplicationController
  def show
    @work = Work.find(params[:work_id])
    @preview = @work.previews.find_by(key: params[:id])
    raise RecordNotFoundError if @preview.nil? || @preview.blank?
    render json: { url: @preview.image.url }
  end
end
