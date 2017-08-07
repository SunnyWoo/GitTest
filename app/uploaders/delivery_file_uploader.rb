# encoding: utf-8
class DeliveryFileUploader < DefaultUploader
  def filename
    original_filename
  end
end
