# Niflheim 式拼版
# ==============
#
# 為預設拼版方式, 效果是將原圖直接上傳, 不做任何拼版處理.
class Imposition::Niflheim
  include Singleton
  include Imposition::Shared

  def slice_size
    1
  end

  # 這裡應該只會拿到一個檔案
  def build_printable(items)
    item = items.first
    files = [download_image(item)]
    files += [item.back_image_path] if item.product.enable_back_image?
    files
  end
end
