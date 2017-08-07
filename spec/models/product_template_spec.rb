# == Schema Information
#
# Table name: product_templates
#
#  id                    :integer          not null, primary key
#  product_model_id      :integer
#  store_id              :integer
#  price_tier_id         :integer
#  name                  :string(255)
#  placeholder_image     :string(255)
#  template_image        :string(255)
#  template_type         :integer
#  aasm_state            :string(255)
#  settings              :json
#  created_at            :datetime
#  updated_at            :datetime
#  image_meta            :json
#  works_count           :integer          default(0)
#  archived_works_count  :integer          default(0)
#  deleted_at            :datetime
#  bought_count          :integer          default(0)
#  special_price_tier_id :integer
#  description           :text
#

require 'spec_helper'

describe ProductTemplate, type: :model do
  it { should belong_to(:product) }
  it { should belong_to(:store) }
  it { should belong_to(:price_tier) }
  it { should belong_to(:special_price_tier) }
  it { should have_many(:works) }
  it { should have_many(:archived_works) }
  it { should have_many(:preview_composers) }
  it { should define_enum_for(:template_type).with(ProductTemplate::TEMPLATE_TYPES) }

  it 'FactoryGirl' do
    expect(build(:product_template)).to be_valid
  end

  it 'before_create#assign_price_tier' do
    product_template = create(:product_template)
    expect(product_template.reload.price_tier).to eq(product_template.product.price_tier)
  end

  describe '#to_ecommerce_tracking' do
    let(:product_template) do
      store = create(:store, name: 'STORE')
      create(:product_template, id: 5566, store: store)
    end

    it 'returns hash type data for google analytics' do
      expect(product_template.to_ecommerce_tracking).to eq(
        id: 5566,
        name: 'Darth Vadar Version',
        category: 'mug',
        brand: 'STORE',
        price: 250.0
      )
    end
  end
end
