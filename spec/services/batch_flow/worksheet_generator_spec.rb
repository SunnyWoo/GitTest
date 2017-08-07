require 'spec_helper'

describe BatchFlow::WorksheetGenerator do
  Given(:batch) do
    double(BatchFlow).tap { |x|
      allow(x).to receive(:number).and_return('SOME_BATCH_NUMBER')
    }
  end
  Given(:product){ build :product_model }
  Given(:item) { build :batch_flow_serial_item }
  Given(:print_items){ [item] }
  Given(:options){ {} }
  Given(:generator) { BatchFlow::WorksheetGenerator.new(batch, product, print_items, options) }

  describe '#generate!' do
    after do
      file = "tmp/TWSOME_CREATION_NUMBER_#{product.name} worksheet.pdf"
      File.delete(file) if File.exist?(file)
    end

    context 'pagination' do
      context '10 items per page(default)' do
        Given { allow(generator).to receive(:generate_page) }

        context 'with 1 items printed' do
          When { generator.generate! }
          Then { expect(generator).to have_received(:generate_page).exactly(1) }
        end

        context 'with 50 items printed' do
          Given(:print_items){ [item] * 50 }
          When { generator.generate! }
          Then { expect(generator).to have_received(:generate_page).exactly(5) }
        end
      end

      context '18 items per page' do
        Given do
          allow(generator).to receive(:generate_page)
          allow(generator).to receive(:columns).and_return(6)
          allow(generator).to receive(:rows).and_return(3)
        end
        Given(:print_items){ [item] * 50 }
        When { generator.generate! }
        Then { expect(generator).to have_received(:generate_page).exactly(3) }
      end
    end

    context 'create the file' do
      Given(:file){ "tmp/TWSOME_BATCH_NUMBER_#{product.name} worksheet.pdf" }
      Given { allow(generator).to receive(:generate_page) }
      Then do
        expect {
          generator.generate!
        }.to change { File.exist?(file) }.from(false).to(true)
      end
    end
  end

  describe '#destination' do
    Given(:options){ { path: '/ABC/DEF', filename: 'xyz' } }
    Then { expect(generator.destination).to eq '/ABC/DEF/xyz.pdf' }
  end

  context 'document_options' do
    context 'default' do
      When(:document_options){ generator.document_options }
      Then { expect(document_options[:grid][:columns]).to eq 2 }
      And { expect(document_options[:grid][:rows]).to eq 5 }
    end

    context 'overwrite by options' do
      Given(:options){ { grid: { columns: 6 } } }
      When(:document_options){ generator.document_options }
      Then { expect(document_options[:grid][:columns]).to eq 6 }
      And { expect(document_options[:grid][:rows]).to eq 5 }
    end
  end
end
