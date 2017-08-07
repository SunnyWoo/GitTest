# == Schema Information
#
# Table name: impositions
#
#  id                       :integer          not null, primary key
#  model_id                 :integer
#  paper_width              :float
#  paper_height             :float
#  definition               :json
#  created_at               :datetime
#  updated_at               :datetime
#  sample                   :string(255)
#  rotate                   :integer
#  type                     :string(255)
#  template                 :string(255)
#  demo                     :boolean          default(FALSE), not null
#  file                     :string(255)
#  flip                     :boolean          default(FALSE)
#  flop                     :boolean          default(FALSE)
#  include_order_no_barcode :boolean          default(FALSE)
#

# Vanaheim 式拼版
# ==============
#
# 只處理一個作品, 將作品重複貼在給定的樣板中, 輸出成 PDF 上傳.
class Imposition::Vanaheim < Imposition
  include IllustratorService::Utils

  mount_uploader :sample, DefaultUploader
  store_accessor :definition, :labels

  def available_params
    [:paper_width, :paper_height, :template, :include_order_no_barcode, labels: [:name, contents: [:locale, :content]]]
  end

  def info
    "紙張大小 #{paper_width}x#{paper_height} (mm)."
  end

  def slice_size
    1
  end

  # 這裡應該只會拿到一個檔案
  def build_printable(items)
    template_path = download_template
    item = items.first
    image_path = download_image(item)
    output_path = "tmp/#{item.id}.pdf"
    qrcode_path = build_qrcode(item)
    IllustratorService.new.build_vanaheim_imposition(item,
                                                     Rails.root + template_path,
                                                     Rails.root + image_path,
                                                     Rails.root + qrcode_path,
                                                     Rails.root + output_path,
                                                     localized_labels(item))
    output_path
  ensure
    File.delete(image_path) if image_path
    File.delete(qrcode_path) if qrcode_path
    fail if $ERROR_INFO
  end

  def build_sample
    template_path = download_template
    sample_path = template_path.gsub('.ai', '.png')
    return if File.exist?(sample_path)
    IllustratorService.new.ai_to_png(Rails.root + template_path,
                                     Rails.root + sample_path)
    update(sample: File.open(sample_path), skip_build_sample: true)
  end

  def download_template
    filename = "tmp/vanaheim-template-#{id}-#{updated_at.to_i}.ai"
    return filename if File.exist?(filename)
    download(template.url, filename)
  end
end
