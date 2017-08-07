namespace :clearfy do

  task order: :environment do
    Work.finished.each do |work|
      if work.layers.count > 1
        work.enqueue_build_print_image
      elsif work.layers.count == 1
        work.remote_print_image_url = work.cover_image.url
      end
      work.save! if work.valid?
    end
  end

end
