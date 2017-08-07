class MarketingReport::GenerateService
  include Concerns::ActsAsServiceObject

  ADAPTAERS = (Dir.entries("#{__dir__}/adapater") - %w(. ..)).map { |file| File.basename(file, '.*') }.freeze

  def initialize(args = {})
    @type = args.symbolize_keys.delete(:type).to_s
    fail InvalidMarketingReportTypeError, caused_by: @type if ADAPTAERS.exclude? @type
    @report_generator = MarketingReport::Adapater.const_get(@type.camelize).new(args)
  end

  private

  attr_reader :type, :report_generator

  # someone who uses the tempfile of payload here one day must remember to call close on it.
  def process(*)
    data = report_generator.send_data
    file.write data
    file.rewind
    file
  end

  def filename
    @filename ||= "#{type}_on_#{DateTime.current}"
  end

  def file
    @file ||= Tempfile.new([filename, '.csv'])
  end
end
