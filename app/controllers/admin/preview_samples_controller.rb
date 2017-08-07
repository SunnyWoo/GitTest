class Admin::PreviewSamplesController < AdminController
  before_action :find_preview_composer

  def index
    @preview_samples = @preview_composer.samples
  end

  private

  def find_preview_composer
    @preview_composer = PreviewComposer.find(params[:preview_composer_id])
  end
end
