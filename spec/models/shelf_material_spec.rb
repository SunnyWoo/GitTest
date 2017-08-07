# == Schema Information
#
# Table name: shelf_materials
#
#  id                    :integer          not null, primary key
#  factory_id            :integer
#  name                  :string(255)
#  serial                :string(255)      not null
#  image                 :string(255)
#  quantity              :integer          default(0), not null
#  safe_minimum_quantity :integer          default(0)
#  scrapped_quantity     :integer          default(0)
#  aasm_state            :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  deleted_at            :datetime
#

require 'rails_helper'

RSpec.describe ShelfMaterial, type: :model do
  it_behaves_like 'soft_delete'

  it { is_expected.to belong_to(:factory) }
  it { is_expected.to validate_presence_of(:serial) }
  it { is_expected.to validate_presence_of(:quantity) }
  it { is_expected.to validate_uniqueness_of(:serial).scoped_to(:factory_id) }
  it 'FactoryGirl' do
    expect(create(:shelf_material)).to be_valid
  end

  context '#stock!' do
    Given(:material) { create :shelf_material, quantity: 10 }
    context 'when params quantity is not integer' do
      Then { expect { material.stock!('a') }.to raise_error(ArgumentError) }
    end

    context 'stock ok' do
      When { material.stock!(10) }
      Then { material.reload.quantity == 20 }
    end
  end

  context '#ship' do
    Given(:material) { create :shelf_material, quantity: 10 }
    context 'when params quantity is not integer' do
      Then { expect { material.ship!('a') }.to raise_error(ArgumentError) }
    end

    context 'when ship quantity bigger than self quantity' do
      Then { expect { material.ship!(11) }.to raise_error(StoreLackingError) }
    end

    context 'ship ok' do
      When { material.ship!(5) }
      Then { material.reload.quantity == 5 }
    end
  end

  describe '#restore!' do
    context 'when quantity is not an integer' do
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 5 }
      Then { expect { material.restore!(nil) }.to raise_exception(ArgumentError) }
    end

    context 'success' do
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 5 }
      When { material.restore!(3) }
      Then { material.quantity == 8 }
    end
  end

  context '#available_quantity' do
    Given(:scrapped_category) { create :shelf_category, name: '报废' }
    Given(:common_category) { create :shelf_category }
    Given(:material) { create :shelf_material, quantity: 10 }
    Given!(:shelf1) { create :shelf, category: scrapped_category, material: material, quantity: 1 }
    Given!(:shelf2) { create :shelf, category: scrapped_category, material: material, quantity: 2 }
    Given!(:shelf3) { create :shelf, category: common_category, material: material, quantity: 3 }
    Then { material.available_quantity == 7 }
  end

  context '#scrap' do
    context 'rails ArgumentError when param is not integer' do
      Given(:material) { create :shelf_material, quantity: 10, scrapped_quantity: 0 }
      Then { expect { material.scrap!('a') }.to raise_error(ArgumentError) }
    end

    context 'rails StoreLackingError scrap quantity is bigger than self quantity' do
      Given(:material) { create :shelf_material, quantity: 10, scrapped_quantity: 0 }
      Then { expect { material.scrap!(11) }.to raise_error(StoreLackingError) }
    end

    context 'rails StoreLackingError scrap quantity is bigger than self quantity' do
      Given(:material) { create :shelf_material, quantity: 10, scrapped_quantity: 0 }
      When { material.scrap!(4) }
      Then { material.reload.quantity == 6 }
      And { material.reload.scrapped_quantity == 4 }
    end
  end
end
