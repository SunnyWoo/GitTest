require 'spec_helper'

describe Admin::ProductCodeForm do
  it { should validate_inclusion_of(:code_type).in_array(%w(category_code material craft spec)) }
  it { is_expected.to validate_presence_of(:code_type) }
  it { is_expected.to validate_presence_of(:code) }

  context '#code_types_collection' do
    Given(:code_types_collection) { [%w(商品大類 category_code), %w(材質 material), %w(工藝 craft), %w(商品規格 spec)] }
    When { I18n.locale = 'zh-TW' }
    Then { Admin::ProductCodeForm.code_types_collection == code_types_collection }
  end

  context '#save!' do
    context 'create spec' do
      Given(:params) do
        {
          code_type: 'spec',
          code: 'A',
          description: 'description'
        }
      end
      Given(:form) { Admin::ProductCodeForm.new(params) }
      When { form.save! }
      Then { ProductSpec.last.code == 'A' }
    end

    context 'create material' do
      Given(:params) do
        {
          code_type: 'material',
          code: 'ABC',
          description: 'description'
        }
      end
      Given(:form) { Admin::ProductCodeForm.new(params) }
      When { form.save! }
      Then { ProductMaterial.last.code == 'ABC' }
    end

    context 'create craft' do
      Given(:params) do
        {
          code_type: 'craft',
          code: '1',
          description: 'description'
        }
      end
      Given(:form) { Admin::ProductCodeForm.new(params) }
      When { form.save! }
      Then { ProductCraft.last.code == '1' }
    end

    context 'create category code' do
      Given(:params) do
        {
          code_type: 'category_code',
          code: 'CA',
          description: 'description'
        }
      end
      Given(:form) { Admin::ProductCodeForm.new(params) }
      When { form.save! }
      Then { ProductCategoryCode.last.code == 'CA' }
    end
  end
end
