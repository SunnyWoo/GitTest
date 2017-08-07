require 'spec_helper'

describe PrintService do
  before do
    create(:print_item)
  end

  describe '#export_sublimate_csv' do
    context 'with all print_items' do
      Given(:result) { PrintService.export_sublimate_csv(PrintItem.all) }
      Then { result.include?(PrintItem.first.timestamp_no.to_s) }
      And { result.include?(PrintItem.first.product_name.to_s) }
    end
  end

  describe '#export_shelves_csv' do
    context 'with all orders' do
      Given!(:shelf) { create(:shelf) }
      Given(:result) { PrintService.export_shelves_csv(Shelf.all) }
      Then { result.include?(shelf.serial.to_s) }
      And { result.include?(shelf.serial_name.to_s) }
    end
  end

  describe '#export_shelf_activities_csv' do
    context 'with all orders' do
      Given!(:shelf) { create :shelf, quantity: 1 }
      Given(:user) { create :user }
      Given do
        shelf.create_activity(:move_out, user: user)
        shelf.create_activity(:move_in, user: user)
      end
      Given(:result) { PrintService.export_shelf_activities_csv(Logcraft::Activity.where(trackable_type: 'Shelf')) }
      Then { result.include?('Move out') }
      And { result.include?('Move in') }
      And { result.include?(shelf.serial_name.to_s) }
    end
  end
end
