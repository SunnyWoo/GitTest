class BatchFlowFileSmuggleService
  include BatchFlow::Utils
  attr_reader :batch_flow, :source_path, :zip_file_name

  def initialize(batch_flow_id, source_path, *specified_folders)
    fail DirectoryMissingError, caused_by: source_path unless Dir.exist? source_path
    @batch_flow = BatchFlow.find batch_flow_id
    @source_path = source_path
    @specified_folders = specified_folders
  end

  def execute
    Dir.mkdir(output_folder) unless Dir.exist?(output_folder)

    begin
      generator_zip_files!
      upload_files!
    ensure
      clean!
    end
  end

  def output_folder
    @output_folder ||= Rails.root.join("tmp", "BATCH_#{@batch_flow.number}_ZIP").to_s
  end

  protected

  def clean!
    FileUtils.rm_rf(output_folder) if File.exist?(output_folder)
    fail if $ERROR_INFO
  end

  def zip_generator
    ZipFileGenerator
  end

  def generator_zip_files!
    @generated_files = if @specified_folders.any?
      @specified_folders.map do |folder|
        source = "#{source_path}/#{folder}"
        destination = "#{output_folder}/#{source_location_code}#{batch_flow.number}_#{folder}.zip"
        zip_generator.new(source, destination).write
        [folder, destination]
      end
    else
      source = source_path
      destination = "#{output_folder}/#{source_location_code}#{batch_flow.number}.zip"
      zip_generator.new(source, destination).write
      [['all', destination]]
    end.to_h
  end

  def upload_files!
    @generated_files.each do |name, filepath|
      attachment = batch_flow.attachments.where(name: name).first_or_initialize
      attachment.file = File.open(filepath)
      attachment.save!
    end
  end
end
