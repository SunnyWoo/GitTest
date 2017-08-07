module Imposition::Shared
  def each_slice_with_index(items, &block)
    items.each_slice(slice_size).each_with_index(&block)
  end

  def slice_count(items)
    items.each_slice(slice_size).size
  end

  def download_image(item)
    uri = URI.parse(item.print_image.escaped_url)
    filename = "tmp/#{item.order_item.order.order_no}-#{item.id}#{File.extname(uri.path)}"
    return filename if File.exist?(filename)
    download(uri, filename)
  end

  def download(uri, filename)
    response = HTTParty.get(uri)
    if response.ok?
      fail "Downloaded empty body from url: #{uri}" if response.body.empty?
      File.open(filename, 'wb') do |f|
        f.write response.body
      end
      filename
    else
      fail "Cannot download from url: #{uri}"
    end
  end
end
