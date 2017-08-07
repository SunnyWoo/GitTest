# == Schema Information
#
# Table name: shelves
#
#  id                    :integer          not null, primary key
#  serial                :string(255)
#  section               :string(255)
#  name                  :string(255)
#  quantity              :integer          default(0)
#  factory_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  serial_name           :string(255)
#  safe_minimum_quantity :integer          default(0)
#  material_id           :integer
#  category_id           :integer
#  deleted_at            :datetime
#

require 'rails_helper'

RSpec.describe Shelf, type: :model do
  it_behaves_like 'soft_delete'

  %i(serial section name).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it { is_expected.to belong_to(:factory) }
  it { is_expected.to validate_presence_of(:serial) }
  it { is_expected.to validate_uniqueness_of(:serial).scoped_to([:factory_id, :material_id]) }

  it 'FactoryGirl' do
    expect(create(:shelf)).to be_valid
  end

  describe '#stock!' do
    context 'when quantity is not an integer' do
      Given(:shelf) { create(:shelf, quantity: 0) }
      Then { expect { shelf.stock!(nil) }.to raise_exception(ArgumentError) }
    end

    context 'success when scrapped_shelf?' do
      Given(:scrapped_category) { create :shelf_category, :scrapped }
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 10 }
      Given(:shelf) { create :shelf, quantity: 0, category: scrapped_category, material: material }
      When { shelf.stock!(2) }
      Then { shelf.quantity == 2 }
      And { material.quantity == 8 }
      And { material.scrapped_quantity == 2 }
    end

    context 'success when scrapped_shelf?' do
      Given(:scrapped_category) { create :shelf_category, :scrapped }
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 10 }
      Given(:shelf) { create :shelf, quantity: 0, category: scrapped_category, material: material }
      When { shelf.stock!(2) }
      Then { shelf.quantity == 2 }
      And { material.quantity == 8 }
      And { material.scrapped_quantity == 2 }
    end

    context 'fail StoreLackingError when scrapped_shelf?' do
      Given(:scrapped_category) { create :shelf_category, :scrapped }
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 1 }
      Given(:shelf) { create :shelf, quantity: 0, category: scrapped_category, material: material }
      Then { expect { shelf.stock!(2) }.to raise_exception(StoreLackingError) }
    end

    context 'fail StoreLackingError when not scrapped_shelf?' do
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 5 }
      Given(:shelf) { create :shelf, quantity: 4, material: material }
      Then { expect { shelf.stock!(2) }.to raise_exception(StoreLackingError) }
    end

    context 'success when scrapped_shelf?' do
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 5 }
      Given(:shelf) { create :shelf, quantity: 2, material: material }
      When { shelf.stock!(2) }
      Then { shelf.quantity == 4 }
      And { material.reload.quantity == 5 }
      And { material.reload.scrapped_quantity == 0 }
    end
  end

  describe '#restore!' do
    context 'when quantity is not an integer' do
      Given(:shelf) { create(:shelf, quantity: 4) }
      Then { expect { shelf.restore!(nil) }.to raise_exception(ArgumentError) }
    end

    context 'success' do
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 5 }
      Given(:shelf) { create :shelf, quantity: 5, material: material }
      When { shelf.restore!(3) }
      Then { shelf.quantity == 8 }
      And { material.reload.quantity == 8 }
    end
  end

  describe '#ship!' do
    context 'when quantity is not an integer' do
      Given(:shelf) { create(:shelf, quantity: 4) }
      Then { expect { shelf.ship!(nil) }.to raise_exception(ArgumentError) }
    end

    context 'success ship when scrapped_shelf? and quantity is enough' do
      Given(:scrapped_category) { create :shelf_category, :scrapped }
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 1 }
      Given(:shelf) { create :shelf, quantity: 5, category: scrapped_category, material: material }
      When { shelf.ship!(2)  }
      Then { shelf.quantity == 3 }
      And { material.reload.quantity == 1 }
    end

    context 'ship when quantity is not enough' do
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 1 }
      Given(:shelf) { create :shelf, quantity: 5, material: material }
      Then { expect { shelf.ship!(6) }.to raise_exception(ArgumentError) }
    end

    context 'success when not scrapped_shelf' do
      Given(:material) { create :shelf_material, scrapped_quantity: 0, quantity: 5 }
      Given(:shelf) { create :shelf, quantity: 5, material: material }
      When { shelf.ship!(3) }
      Then { shelf.quantity == 2 }
      And { material.reload.quantity == 2 }
    end
  end

  describe '#move_out!' do
    context 'when quantity is not an integer' do
      Given(:shelf) { create(:shelf, quantity: 4) }
      Then { expect { shelf.ship!(nil) }.to raise_exception(ArgumentError) }
    end

    context 'when quantity is not enough' do
      Given(:shelf) { create(:shelf, quantity: 4) }
      Then { expect { shelf.ship!(5) }.to raise_exception(ArgumentError) }
    end

    context 'move_out success' do
      Given(:shelf) { create(:shelf, quantity: 4) }
      When { shelf.move_out!(2) }
      Then { shelf.quantity == 2 }
    end
  end

  describe '#move_in!' do
    context 'when quantity is not an integer' do
      Given(:shelf) { create(:shelf, quantity: 4) }
      Then { expect { shelf.ship!(nil) }.to raise_exception(ArgumentError) }
    end

    context 'move_in success' do
      Given(:shelf) { create(:shelf, quantity: 2) }
      When { shelf.move_in!(2) }
      Then { shelf.quantity == 4 }
    end
  end

  describe 'scrapped_shelf?' do
    context 'return true' do
      Given(:scrapped_category) { create :shelf_category, :scrapped }
      Given(:shelf) { create :shelf, category: scrapped_category }
      Then { shelf.scrapped_shelf? == true }
    end

    context 'return false' do
      Given(:shelf) { create :shelf }
      Then { shelf.scrapped_shelf? == false }
    end
  end
end
