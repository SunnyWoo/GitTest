module ImageUploader
  def uploaded_file
    data = params[:data]
    data_index = data.index('base64') + 7
    data_format = data.match(/image\/(\w+)/)[1]
    filedata = data[data_index..-1]
    decoded_image = Base64.decode64(filedata)

    filename = "uploaded_order_image.#{data_format}"
    file = Tempfile.new(filename)
    file.binmode
    file.write(decoded_image)
    ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: filename)
  end
end
