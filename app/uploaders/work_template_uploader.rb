# encoding: utf-8

class WorkTemplateUploader < DefaultUploader
  def w320
    on_the_fly_process(resize_to_fit: [320, 320])
  end

  def w640
    on_the_fly_process(resize_to_fit: [640, 640])
  end
end
