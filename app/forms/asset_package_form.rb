class AssetPackageForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :file
  attr_reader :asset_package

  validate :detect_missing_coating_file

  def save
    valid? && create_asset_package && create_assets
  end

  def create_asset_package
    @asset_package = AssetPackage.new(name: File.basename(file.original_filename, '.*'))
    @asset_package.save!
  end

  def create_assets
    create_sticker_assets
    create_coating_assets
    create_foiling_assets
  end

  def create_sticker_assets
    categorized_entries[:sticker].each do |entry|
      asset_package.assets.create(type: 'sticker', raster: entry[:file])
    end
  end

  def create_coating_assets
    categorized_entries[:coating].each do |entry|
      asset_package.assets.create(type: 'coating', raster: entry[:png_file],
                                                   vector: entry[:svg_file])
    end
  end

  def create_foiling_assets
    categorized_entries[:foiling].each do |entry|
      asset_package.assets.create(type: 'foiling', vector: entry[:file])
    end
  end

  def zip_entries
    @zip_entries ||= []
  end

  def categorized_entries
    @categorized_entries ||= { sticker: [], coating: [], foiling: [] }
  end

  def extract_zip_entries
    zip_extractor = ZipExtractor.new(file, /^(?!__MACOSX).*\.(png|svg)/)
    zip_entries.concat(zip_extractor.extract_zip_entries)
   rescue Zip::Error => e
    errors.add(:file, e.message)
  end

  def categorize_zip_entries
    zip_entries.each do |entry|
      case entry[:path]
      when /^sticker/ then categorized_entries[:sticker] << entry
      when /^coating/ then categorized_entries[:coating] << entry
      when /^foiling/ then categorized_entries[:foiling] << entry
      end
    end
    merge_coating_entries
  end

  def merge_coating_entries
    categorized_entries[:coating] = categorized_entries[:coating].inject({}) do |hash, entry|
      name = entry[:name]
      hash[name] ||= { name: name }
      case entry[:path]
      when /\.svg$/
        hash[name][:svg_path] = entry[:path]
        hash[name][:svg_file] = entry[:file]
      when /\.png$/
        hash[name][:png_path] = entry[:path]
        hash[name][:png_file] = entry[:file]
      end
      hash
    end.values
  end

  def detect_missing_coating_file
    extract_zip_entries
    categorize_zip_entries

    categorized_entries[:coating].each do |entry|
      if entry[:png_file].blank?
        errors.add(:file, "missing file `#{entry[:name]}.png`")
      end
      if entry[:svg_file].blank?
        errors.add(:file, "missing file `#{entry[:name]}.svg`")
      end
    end
  end
end
