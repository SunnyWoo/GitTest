module Csvify
  def visit result, hash, parent_key = ''
    hash.each do |key, value|
      if value.is_a?(Hash)
        visit(result, value, "#{parent_key}.#{key}")
      else
        result["#{parent_key}.#{key}"] = value
      end
    end
  end

  def export_to_csv(file, data)
    File.open "#{file.to_s.split('.')[0..1].join('.')}.csv", 'w' do |f|
      f.write(
        CSV.generate do |csv|
          data.each { |row| csv << row }
        end
      )
    end
  end
end