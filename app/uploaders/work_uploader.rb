# encoding: utf-8

class WorkUploader < DefaultWithMetaUploader
  PREFERED_DPI = '300'
  ICC_PROFILE = 'PSO_Coated_300_NPscreen_ISO12647_eci.icc'
  optimize!

  version :crop do
    process :crop
  end

  def share
    on_the_fly_process(resize_and_pad: [390, 390])
  end

  def mobile
    on_the_fly_process(resize_and_pad: [290, 290])
  end

  # Protected: 判斷 model 是否為 Work
  #
  # Returns Boolean
  def is_work?(picture)
    model.is_a? Work
  end

  def sample
    on_the_fly_process(resize_to_limit: [nil, 200])
  end
end
