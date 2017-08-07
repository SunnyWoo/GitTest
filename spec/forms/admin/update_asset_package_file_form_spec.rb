require 'spec_helper'

describe Admin::UpdateAssetPackageFileForm do
  Given(:small_package) { File.open("#{Rails.root}/spec/file/small_package.zip") }
  Given(:large_package) { File.open("#{Rails.root}/spec/file/large_package.zip") }
  Given(:cp_resource) { create(:cp_resource) }
  Given(:form) do
    Admin::UpdateAssetPackageFileForm.new(small_package: small_package,
                                          large_package: large_package,
                                          version: cp_resource.version)
  end

  context 'initialize' do
    context 'presence_of small package' do
      When(:small_package) { nil }
      Then { form.valid? == false }
    end

    context 'presence_of large package' do
      When(:large_package) { nil }
      Then { form.valid? == false }
    end

    context 'check version' do
      Then { form.version == cp_resource.version }
    end
  end

  context 'validate_dirs' do
    Given { allow(form).to receive(:small_package_filepath_list).and_return(%w(colorsticker/1.webp frame/1.webp line/1.webp)) }
    When { form.send(:validate_dirs) }
    Then { form.errors.messages.key?(:small_package) }
    And { form.errors.messages.key?(:large_package) == false }
  end

  context 'validate_filenames' do
    context 'with correct file name' do
      When { form.send(:validate_filenames) }
      Then { form.errors.blank? }
    end
    context 'with error file name' do
      Given { allow(form).to receive(:small_package_filename_list).and_return(%w(colorsticker/1.webp)) }
      When { form.send(:validate_filenames) }
      Then { form.errors.messages.key?(:small_package) }
    end
  end

  context 'validate_filepath' do
    context 'with correct file path' do
      When { form.send(:validate_filenames) }
      Then { form.errors.blank? }
    end
    context 'with error file path' do
      Given { allow(form).to receive(:small_package_filepath_list).and_return(%w(colorsticker/s_1.webp)) }
      Given { allow(form).to receive(:large_package_filepath_list).and_return(%w(colorsticker/2.webp)) }
      When { form.send(:validate_filepath) }
      Then { form.errors.messages.key?(:large_package) }
    end
  end
end
