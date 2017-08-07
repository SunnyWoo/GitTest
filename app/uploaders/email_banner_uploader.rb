class EmailBannerUploader < DefaultWithMetaUploader
  def s600
    on_the_fly_process(resize_to_fill: [600, 310])
  end
end
