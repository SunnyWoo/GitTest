require 'spec_helper'

describe BatchFlow::FileDumpService do
  Given(:service){ BatchFlow::FileDumpService.new(batch) }
  Given(:batch) do
    double(BatchFlow).tap { |x|
      allow(x).to receive(:number).and_return('SOME_BATCH_NUMBER')
      allow(x).to receive(:id).and_return('ID')
      allow(x).to receive(:print_item_ids).and_return(item_ids)
    }
  end
  Given(:item_ids){ [] }
  Given!(:current_time){ Time.zone.now }
  Given do
    Timecop.freeze(current_time)
    allow(BatchFlow::SummaryTableGenerator).to receive(:new).and_return(mock_generator)
  end

  Given(:temp_dir) { "tmp/BATCH_ID_#{current_time.strftime('%Y%m%d%H%M%S')}" }
  Given(:destination){ Rails.root.join(temp_dir, "TW#{batch.number}").to_s }
  Given(:mock_generator) do
    double(BatchFlow::SummaryTableGenerator).tap do |g|
      allow(g).to receive(:generate!)
    end
  end

  describe '#perform!' do
    after do
      FileUtils.rm_rf(temp_dir) if Dir.exist?(temp_dir)
    end

    context 'generate directory by product' do
      Given {
        allow(service).to receive(:generate_product_directory)
        allow(service).to receive(:wrap_items).and_return(wrap_items)
      }

      context 'items with same product' do
        Given(:product){ create :product_model }
        Given(:i1){ build :batch_flow_serial_item, product: product }
        Given(:i2){ build :batch_flow_serial_item, product: product }
        Given(:wrap_items) { [i1, i2] }
        Given(:item_ids) { [i1.id, i2.id] }
        When { service.perform! }
        Then { expect(service).to have_received(:generate_product_directory).with(product, wrap_items).exactly(1) }
      end

      context 'items over 2 products' do
        Given(:product1){ create :product_model }
        Given(:product2){ create :product_model }
        Given(:i1){ build :batch_flow_serial_item, product: product1 }
        Given(:i2){ build :batch_flow_serial_item, product: product1 }
        Given(:i3){ build :batch_flow_serial_item, product: product2 }
        Given(:i4){ build :batch_flow_serial_item, product: product2 }
        Given(:wrap_items) { [i1, i2, i3, i4] }
        Given(:item_ids) { [i1.id, i2.id, i3.id, i4.id] }
        When { service.perform! }
        Then { expect(service).to have_received(:generate_product_directory).with(product1, [i1, i2]).exactly(1) }
        And { expect(service).to have_received(:generate_product_directory).with(product2, [i3, i4]).exactly(1) }
        And { expect(service).to have_received(:generate_product_directory).exactly(2) }
      end
    end

    context 'called table generator to generate summary table' do
      Given {
        allow(service).to receive(:generate_product_directory)
        allow(service).to receive(:wrap_items).and_return(wrap_items)
      }
      Given(:product){ create :product_model }
      Given(:i1){ build :batch_flow_serial_item, product: product }
      Given(:wrap_items) { [i1] }
      Given(:item_ids) { [i1.id] }
      Given(:document_destination) { "#{destination}/document" }
      When { service.perform! }
      Then { expect(BatchFlow::SummaryTableGenerator).to have_received(:new).with(batch, wrap_items, path: document_destination) }
      And { expect(mock_generator).to have_received(:generate!) }
    end

    context 'returned the destination directory' do
      When(:ans){ service.perform! }
      Then{ expect(ans).to eq destination }
    end
  end

  describe '#generate_product_directory' do
    after do
      FileUtils.rm_rf(temp_dir) if Dir.exist?(temp_dir)
    end

    Given(:product){ create :product_model }
    Given(:documents_path) { "#{destination}/document" }
    Given(:images_path) { "#{destination}/image" }
    Given(:print_image_directory){ "#{images_path}/#{product.name}" }
    Given(:items){ [] }
    Given {
      Dir.mkdir(temp_dir)
      Dir.mkdir(destination)
      Dir.mkdir(documents_path)
      Dir.mkdir(images_path)
      allow(BatchFlow::WorksheetGenerator).to receive(:new).and_return(mock_generator)
      allow(service).to receive(:copy_print_image)
      service.instance_variable_set('@images_path', images_path)
      service.instance_variable_set('@documents_path', documents_path)
    }

    context 'called worksheet generator' do
      When { service.generate_product_directory(product, items) }
      Then { expect(BatchFlow::WorksheetGenerator).to have_received(:new).with(batch, product, items, path: documents_path) }
      And { expect(mock_generator).to have_received(:generate!) }
    end

    context 'called copy_print_image with print items grouped by order item' do
      Given(:items){ [i1, i2, i3, i4] }
      Given(:order_item1){ create :order_item }
      Given(:order_item2){ create :order_item }
      Given(:i1){ build :batch_flow_serial_item, order_item: order_item1, product: product }
      Given(:i2){ build :batch_flow_serial_item, order_item: order_item1, product: product }
      Given(:i3){ build :batch_flow_serial_item, order_item: order_item2, product: product }
      Given(:i4){ build :batch_flow_serial_item, order_item: order_item2, product: product }

      When { service.generate_product_directory(product, items) }
      Then { expect(service).to have_received(:copy_print_image).exactly(2) }
      And { expect(service).to have_received(:copy_print_image).with(print_image_directory, product, [i1, i2]).exactly(1) }
      And { expect(service).to have_received(:copy_print_image).with(print_image_directory, product, [i3, i4]).exactly(1) }
    end
  end
end
