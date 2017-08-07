require 'spec_helper'

describe BatchFlow::SummaryTableGenerator do
  after do
    file = 'tmp/SOME_BATCH_NUMBER_SummaryTable.csv'
    File.delete(file) if File.exist?(file)
  end

  def serial_item(serial_in_order = 1, serial_in_quantity = 1, attrs = {})
    attrs[:order_item] ||= create(:order_item, quantity: 1, order: create(:order))
    attrs[:product] ||= create(:product_model)

    create(:print_item, attrs).becomes(
      BatchFlow::FileDumpService::SerialItem
    ).tap do |item|
      item.order_item_serial = serial_in_order
      item.quantity_serial = serial_in_quantity
    end
  end

  def mark_as_reprint(*items)
    items.map do |item|
      allow(item).to receive(:is_reprint?).and_return(true)
      item
    end
  end

  Given(:deadline){ Time.zone.now.days_since(10) }
  Given(:batch) do
    double(BatchFlow).tap { |x|
      allow(x).to receive(:number).and_return('SOME_BATCH_NUMBER')
      allow(x).to receive(:number_with_source).and_return('TWSOME_BATCH_NUMBER')
      allow(x).to receive(:deadline).and_return(deadline)
    }
  end

  Given(:generator) { BatchFlow::SummaryTableGenerator.new(batch, print_items) }
  Given(:print_items) { [] }

  describe '#header' do
    When(:header) { generator.header }
    Then { expect(header.size).to eq 8 }
    And { expect(header[0]).to eq 'Batch Number' }
    And { expect(header[1]).to eq 'Expected Delivery Date' }
    And { expect(header[2]).to eq 'Location' }
    And { expect(header[3]).to eq 'Item Number' }
    And { expect(header[4]).to eq 'Order Number' }
    And { expect(header[5]).to eq 'Product Name' }
    And { expect(header[6]).to eq 'Qt.' }
    And { expect(header[7]).to eq 'Shipping Number' }
  end

  describe '#generate!' do
    Given(:i1){ serial_item }
    Given(:i2){ serial_item }
    Given(:i3){ serial_item }
    Given(:i4){ serial_item }

    context 'separate items by reprint or not' do
      Given do
        allow(generator).to receive(:generate_file!)
        allow(generator).to receive(:append_rows)
      end
      Given(:print_items) { reprint_items + normal_items }
      When do
        reprint_items.each do |item|
          allow(item).to receive(:is_reprint?).and_return(true)
        end
      end

      context 'All are normal' do
        Given!(:reprint_items) { [] }
        Given!(:normal_items) { [i1, i2, i3, i4] }
        When { generator.generate! }
        Then { expect(generator).to have_received(:append_rows).with(normal_items).exactly(1) }
        And { expect(generator).to have_received(:append_rows).exactly(1) }
      end

      context 'All are reprint' do
        Given!(:reprint_items) { mark_as_reprint(i1, i2, i3, i4) }
        Given!(:normal_items) { [] }
        When { generator.generate! }
        Then { expect(generator).to have_received(:append_rows).with(reprint_items).exactly(1) }
        And { expect(generator).to have_received(:append_rows).exactly(1) }
      end

      context 'Includes both' do
        Given!(:reprint_items) { mark_as_reprint(i4) }
        Given!(:normal_items) { [i1, i2, i3] }
        When { generator.generate! }
        Then { expect(generator).to have_received(:append_rows).with(reprint_items).exactly(1) }
        And { expect(generator).to have_received(:append_rows).with(normal_items).exactly(1) }
      end
    end

    context 'return file path as result' do
      Given { allow(generator).to receive(:append_rows) }
      When(:path){ generator.generate! }
      Then { expect(path).to eq 'tmp/TWSOME_BATCH_NUMBER_SummaryTable.csv' }
    end

    context 'generated the file' do
      Given(:group_class){ BatchFlow::SummaryTableGenerator::OrderRowsGroup }
      Given!(:group) do
        group = double(group_class)
        allow(group_class).to receive(:new).and_return(group)
        allow(group).to receive(:to_rows).and_return([%w(col1 col2 col3)])
        group
      end
      Given(:print_items){ [i1, i2, i3, i4] }
      Given(:content_lines){ File.open(path).readlines }
      When(:path){ generator.generate! }

      context 'had retrieved data from groups' do
        Then { expect(group_class).to have_received(:new).exactly(4) }
        And { expect(group_class).to have_received(:new).with(batch, i1.order, [i1]).exactly(1) }
        And { expect(group_class).to have_received(:new).with(batch, i2.order, [i2]).exactly(1) }
        And { expect(group_class).to have_received(:new).with(batch, i3.order, [i3]).exactly(1) }
        And { expect(group_class).to have_received(:new).with(batch, i4.order, [i4]).exactly(1) }
        And { expect(group).to have_received(:to_rows).exactly(4) }
      end

      context 'content_lines included items and stats' do
        Then { expect(content_lines.size).to eq 12 } # 1 header, 4 items, 1 divider, 1 title, 1 header, 4 products
      end

      context 'content of items' do
        When(:content) { content_lines[0..4] }
        Then do
          expect(content).to eq(
            [
              "Batch Number,Expected Delivery Date,Location,Item Number,Order Number,Product Name,Qt.,Shipping Number\n",
              "col1,col2,col3\n",
              "col1,col2,col3\n",
              "col1,col2,col3\n",
              "col1,col2,col3\n"
            ]
          )
        end
      end

      context 'content of state' do
        When(:content) { content_lines[5..11] }
        Then do
          expect(content).to eq(
            [
              "\n",
              "Product Stats\n",
              "Product Name,Quantity\n",
              "#{i1.product.name},1\n",
              "#{i2.product.name},1\n",
              "#{i3.product.name},1\n",
              "#{i4.product.name},1\n"
            ]
          )
        end
      end
    end
  end

  describe '#destination' do
    Given(:generator) { BatchFlow::SummaryTableGenerator.new(batch, print_items, path: '/ABC/DEF', filename: 'xyz') }
    Then { expect(generator.destination).to eq '/ABC/DEF/xyz.csv' }
  end

  describe BatchFlow::SummaryTableGenerator::OrderRowsGroup do
    Given(:group) { BatchFlow::SummaryTableGenerator::OrderRowsGroup.new(batch, order, print_items) }
    Given(:product1) { create :product_model, external_code: 'AB' }
    Given(:product2) { create :product_model, external_code: 'CD' }
    Given(:quantity1) { 3 }
    Given(:quantity2) { 2 }

    Given(:order) { create :order }
    Given(:order_item1) { create :order_item, quantity: 3, order: order }
    Given(:order_item2) { create :order_item, quantity: 2, order: order }
    Given(:row1){ rows[0] }
    Given(:row2){ rows[1] }
    Given(:order_code) { order.id.to_s(16)[0, 5].rjust(5, '0').upcase }

    Given!(:print_items) do
      [].tap do |items|
        quantity1.times do |i|
          items << serial_item(1, i.succ, order_item: order_item1, product: product1)
        end

        quantity2.times do |i|
          items << serial_item(2, i.succ, order_item: order_item2, product: product2)
        end
      end
    end

    When(:rows){ group.to_rows }
    Then { expect(rows.size).to eq 2 }
    And { expect(row1).to eq ['TWSOME_BATCH_NUMBER', deadline.to_date.to_s, 'TW', "#{order_code}_01_AB_#{quantity1}", order.order_no, product1.name, quantity1, ''] }
    And { expect(row2).to eq ['TWSOME_BATCH_NUMBER', deadline.to_date.to_s, 'TW', "#{order_code}_02_CD_#{quantity2}", order.order_no, product2.name, quantity2, ''] }
  end
end
