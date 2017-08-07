require 'spec_helper'

describe Store::StatusForm do
  let(:template) { create :product_template }
  subject { Store::StatusForm.new template, {} }
  it { should validate_presence_of(:price_tier_id) }
  it { should validate_inclusion_of(:aasm_state).in_array(ProductTemplate.aasm.states.map(&:name).map(&:to_s)) }
end
