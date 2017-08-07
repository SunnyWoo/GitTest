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

# Alfheim 式拼版
# ==============
#
# 可處理多個作品, 將作品貼在給定的樣板中, 輸出成 PDF 上傳.
class Imposition::Alfheim < Imposition
  mount_uploader :sample, DefaultUploader
  store_accessor :definition, :labels, :slice_size

  def available_params
    [:paper_width, :paper_height, :template, :slice_size, :include_order_no_barcode, labels: [:name, contents: [:locale, :content]]]
  end

  def info
    "紙張大小 #{paper_width}x#{paper_height} (mm), 共 #{slice_size} 模."
  end

  def slice_size
    3
  end

  def build_printable(items)
    generator = IllustratorService::AlfheimImpositionArgumentsGenerator.new(self, items)

    begin
      arguments = generator.generate
      IllustratorService.new.build_alfheim_imposition(arguments)
      arguments[:output]
    ensure
      generator.clean
    end
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
