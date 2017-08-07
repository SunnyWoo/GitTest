require 'zip'

class ZipExtractor
  attr_reader :entries

  def initialize(zip, format)
    @zip = zip
    @format = format
    @entries = []
  end

  def extract_zip_entries
    Zip::File.open(@zip.path) do |zip_file|
      zip_file.each do |entry|
        entry_name = entry.name.force_encoding('utf-8')
        next unless entry_name =~ @format
        @entries << { name: File.basename(entry_name, '.*'),
                      filename: File.basename(entry_name),
                      path: entry_name,
                      file: create_tempfile_for_entry(entry, entry_name) }
      end
    end

    entries
  end

  def create_tempfile_for_entry(entry, filename)
    Zip.on_exists_proc = true

    basename = File.basename(filename, '.*')
    extname = File.extname(filename)
    Tempfile.new([basename, extname]).tap do |tempfile|
      entry.extract(tempfile.path)
      tempfile.binmode
    end
  end
end
