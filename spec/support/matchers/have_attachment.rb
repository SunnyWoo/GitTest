RSpec::Matchers.define :have_attachment do |column|
  match do |model|
    attachment = create(:attachment)
    model.update("#{column}_aid": attachment.aid)
    model.send(column).store_md5sum_meta == attachment.file.store_md5sum_meta
  end
end
