require 'spec_helper'

describe PrinterUploaderService do
  Given!(:print_item) { create :print_item, :with_archived_standardized_work_item }
  Given!(:file_gateway) { create :file_gateway }
  Given { allow_any_instance_of(FileGateway).to receive(:upload).and_return(true) }
  Given { print_item.upload! }
  Given(:service) { PrinterUploaderService.new(print_item.id, file_gateway.id) }

  context '#execute' do
    Given { allow(service).to receive(:upload_files_collection).and_return([]) }
    When { service.execute }
    Then { print_item.reload.printed? }
  end

  context '#urls_for_download' do
    context 'style: print_image' do
      Given(:print_image) { double(:print_image, escaped_url: 'escaped_url') }
      Given { allow(service.print_item).to receive(:print_image).and_return(print_image) }
      Then { service.send(:urls_for_download, 'print_image') == %w(escaped_url) }
    end

    context 'style: output_files' do
      Given(:output_files) { %w(1.jpg 2.jpg) }
      Given { allow(service.print_item).to receive(:output_files).and_return(output_files) }
      Then { service.send(:urls_for_download, 'output_files') == output_files }
    end

    context 'style: white_image' do
      Given(:print_image) { double(:print_image) }
      Given { allow(print_image).to receive(:escaped_url).with(:gray).and_return('gray.jpg') }
      Given { allow(service.print_item).to receive(:print_image).and_return(print_image) }
      Then { service.send(:urls_for_download, 'white_image') == %w(gray.jpg) }
    end

    context 'defualt: return []' do
      Then { service.send(:urls_for_download, 'others') == [] }
    end
  end

  context '#tmp_file_name' do
    Given { allow(service.print_item).to receive(:order).and_return(double(:order, order_no: '12341TW')) }
    Then { service.send(:tmp_file_name, 'output_files', '.jpg') == "tmp/12341TW-#{print_item.id}-0.jpg" }
    And { service.send(:tmp_file_name, 'white_image', '.jpg') == "tmp/#{print_item.timestamp_no}-#{print_item.id}-white.jpg" }
    And { service.send(:tmp_file_name, 'image', '.jpg') == "tmp/#{print_item.timestamp_no}-#{print_item.id}.jpg" }
  end

  context '#download_files_to_upload' do
    Given(:file_name) { "tmp/#{print_item.timestamp_no}-#{print_item.id}.jpg" }
    Given { allow(service).to receive(:urls_for_download).and_return(%w(spec/fixtures/test.jpg)) }
    Given { allow(File).to receive(:open).with(file_name, 'wb') }
    Then { service.send(:download_files_to_upload, 'image') == [file_name] }
  end
end
