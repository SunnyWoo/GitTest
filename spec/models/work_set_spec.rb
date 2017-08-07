# == Schema Information
#
# Table name: work_sets
#
#  id                  :integer          not null, primary key
#  designer_id         :integer
#  model_id            :integer
#  work_ids            :integer          default([]), is an Array
#  created_at          :datetime
#  updated_at          :datetime
#  zip_filename        :string(255)
#  zip_entry_filenames :string(255)      default([]), is an Array
#  designer_type       :string(255)
#

require 'rails_helper'

RSpec.describe WorkSet, type: :model do
  describe '#works' do
    it 'can be assign by work scope' do
      work = create(:standardized_work)
      work_set = WorkSet.new
      work_set.works = StandardizedWork.all
      expect(work_set.works).to eq([work])
    end

    it 'can be assign by work array' do
      work = create(:standardized_work)
      work_set = WorkSet.new
      work_set.works = [work]
      expect(work_set.works).to eq([work])
    end
  end

  describe '#works' do
    it 'can be assign by work scope' do
      work = create(:standardized_work)
      work_set = WorkSet.new
      work_set.works = StandardizedWork.all
      expect(work_set.works).to eq([work])
    end

    it 'can be assign by work array' do
      work = create(:standardized_work)
      work_set = WorkSet.new
      work_set.works = [work]
      expect(work_set.works).to eq([work])
    end
  end

  describe '#zip' do
    let(:file) { ActionDispatch::Http::UploadedFile.new(tempfile: File.open(path), filename: File.basename(path)) }
    let(:designer) { create(:designer) }

    it 'do nothing for nil zip' do
      expect { WorkSet.create!(designer: designer, zip: nil) }.not_to raise_error
    end

    context 'when zip is not a zip file' do
      let(:path) { Rails.root + 'spec/fixtures/work_sets/cp_i6_1028x1772_walkr_apple.jpg' }

      it 'have errors in zip' do
        work_set = WorkSet.new(zip: file)
        expect(work_set).not_to be_valid
        expect(work_set.errors[:zip]).to include(/Zip end of central directory signature not found/)
      end
    end

    context 'when zip is a zip file' do
      let(:path) { Rails.root + 'spec/fixtures/work_sets/cp_i6_1028x1772.zip' }
      let(:designer) { create(:designer) }

      context 'but any image size is not equal to product size' do
        it 'have errors in zip' do
          product = create(:product_model)
          work_set = WorkSet.new(designer: designer, product: product, zip: file)
          expect(work_set).not_to be_valid
          expect(work_set.errors[:zip]).to include(/is not fit selected product/)
        end
      end

      context 'but every image size is equal to product size' do
        it 'does not have errors in zip' do
          product = create(:product_model, width: 87, height: 150)
          work_set = WorkSet.new(designer: designer, product: product, zip: file)
          expect(work_set).to be_valid
          expect(work_set.errors[:zip]).not_to include(/is not fit selected product/)
        end

        it 'stores zip filename to zip_filename' do
          product = create(:product_model, width: 87, height: 150)
          work_set = WorkSet.new(designer: designer, product: product, zip: file)
          expect(work_set).to be_valid
          expect(work_set.zip_filename).to eq('cp_i6_1028x1772.zip')
        end

        it 'stores zip entry filenames to zip_entry_filenames' do
          product = create(:product_model, width: 87, height: 150)
          work_set = WorkSet.new(designer: designer, product: product, zip: file)
          expect(work_set).to be_valid
          expect(work_set.zip_entry_filenames).to eq(%w(cp_i6_1028x1772/cp_i6_1028x1772_walkr_apple.jpg))
        end

        it 'creates work before save' do
          product = create(:product_model, width: 87, height: 150)
          work_set = WorkSet.create(designer: designer, product: product, zip: file)
          expect(PreviewsBuilder.jobs.size).to eq(0)
          expect(work_set.works).not_to be_empty
        end

        it 'creates work before save with build_previews' do
          product = create(:product_model, width: 87, height: 150)
          work_set = WorkSet.create(designer: designer, product: product, zip: file, build_previews: true)
          expect(PreviewsBuilder.jobs.size).to eq(1)
          expect(work_set.works).not_to be_empty
        end

        it 'clears zip entries on save' do
          product = create(:product_model, width: 87, height: 150)
          work_set = WorkSet.create(designer: designer, product: product, zip: file)
          expect(work_set.zip).to be_nil
          expect(work_set.zip_entries).to be_empty
        end
      end
    end

    context 'when zip contains pdf files' do
      let(:path) { Rails.root + 'spec/fixtures/work_sets/i5-pdf.zip' }
      let(:designer) { create(:designer) }

      it 'creates work before save' do
        product = create(:product_model, width: 87, height: 150)
        work_set = WorkSet.create(designer: designer, product: product, zip: file, aasm_state: :published)
        expect(work_set.works).not_to be_empty
        work = work_set.works.first
        expect(work.output_files).not_to be_empty
        expect(work.published?).to be_truthy
      end
    end

    # see directory structure in the zip file here: http://imgur.com/Fa1GIZg
    context 'when zip is in complex format' do
      Given(:path) { Rails.root + 'spec/fixtures/work_sets/cp_i5_886x1594_complex.zip' }
      Given(:designer) { create(:designer) }
      Given(:product) { create(:product_model, width: 75, height: 135) }
      Given(:work_set) { WorkSet.create(designer: designer, product: product, zip: file) }
      Given(:get_work) { work_set.works.each_with_object({}) { |work, hsh| hsh[work.name] = work } }
      # creates works successfully
      Then { expect(work_set).to be_valid }
      Then { work_set.works.count == 9 }

      # creates work if work only has previews
      Then { get_work['i51'].previews.count == 1 }
      And { expect(get_work['i51'].previews).to be_exist(key: 'order-image') }

      # creates work if work only has output files
      And { get_work['i52'].output_files.count == 1 }
      And { expect(get_work['i52'].output_files).to be_exist(key: 'print-image') }

      # creates work if work has many previews
      And { get_work['i53'].previews.count == 2 }
      And { expect(get_work['i53'].previews).to be_exist(key: 'order-image') }
      And { expect(get_work['i53'].previews).to be_exist(key: 'another-preview') }

      # creates work if work has many output files
      And { get_work['i54'].output_files.count == 2 }
      And { expect(get_work['i54'].output_files).to be_exist(key: 'print-image') }
      And { expect(get_work['i54'].output_files).to be_exist(key: 'another-output-file') }

      # creates work if work has previews and output files
      And { get_work['i55'].previews.count == 1 }
      And { get_work['i55'].output_files.count == 1 }
      And { expect(get_work['i55'].output_files).to be_exist(key: 'print-image') }
      And { expect(get_work['i55'].previews).to be_exist(key: 'order-image') }

      # creates work from standalone image in whatever directory
      And { get_work['i56'].output_files.count == 1 }
      And { expect(get_work['i56'].output_files).to be_exist(key: 'print-image') }

      # creates work from standalone image in root directory
      And { get_work['i57'].output_files.count == 1 }
      And { expect(get_work['i57'].output_files).to be_exist(key: 'print-image') }

      # check previews key: order-image position is 1st
      And { get_work['i58'].previews.count == 4 }
      And { get_work['i58'].previews.find_by(key: 'order-image').position == 1 }
      And { get_work['i58'].previews.map(&:key) == ['order-image', 'a1', 'a2', 'a3'] }

      # check previews key: order-image position is 1st
      And { get_work['i59'].previews.count == 4 }
      And { get_work['i59'].previews.find_by(key: 'order-image').position == 1 }
      And { get_work['i59'].previews.map(&:key) == ['order-image', '2-order-image', 'a1', 'order-image1'] }
    end
  end
end
