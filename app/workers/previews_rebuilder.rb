class PreviewsRebuilder
  include Sidekiq::Worker

  def perform(model_id)
    Work.where(model_id: model_id).is_public.each_slice(5).each_with_index do |works, index|
      works.each do |work|
        if work.print_image.blank?
          work.enqueue_build_previews_by_cover_image(index.minutes)
        else
          work.enqueue_build_previews_by_print_image(index.minutes)
        end
      end
    end
  end
end
