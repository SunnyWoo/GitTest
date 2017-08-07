# Product Model 的 Overlay Image 所使用的 uploader
#
# 因為後台上傳的 overlay image 必須要與 print image 解析度一樣，
# 所以某些商品的上傳圖片大小會很大，比如說 T-shirt 的圖（5240x5000）就會達到 8MB，
# 使用編輯器時遇到這麼大張的圖在某些行動裝置瀏覽器上會 crash，而且下載時間很久，
# 因此使用編輯器可能的最大寬度，重新製作一個較小的版本。
class ProductModelOverlayUploader < DefaultUploader
  EXPECTED_MAX_EDITOR_SIZE = [1000, 1000]
  EXPECTED_MAX_EDITOR_SIZE_2X = [2000, 2000]

  def editor_optimization
    Hashie::Mash.new(
      x1: on_the_fly_process(resize_to_fit: EXPECTED_MAX_EDITOR_SIZE),
      x2: on_the_fly_process(resize_to_fit: EXPECTED_MAX_EDITOR_SIZE_2X)
    )
  end
end
