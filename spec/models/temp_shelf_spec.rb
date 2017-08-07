# == Schema Information
#
# Table name: temp_shelves
#
#  id            :integer          not null, primary key
#  print_item_id :integer
#  serial        :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  description   :string(255)
#

require 'rails_helper'

RSpec.describe TempShelf, type: :model do
  it { is_expected.to strip_attribute(:serial) }
  it { is_expected.to validate_presence_of(:serial) }

  context '#check_print_item' do
    Given(:print_item) { create :print_item, aasm_state: :sublimated }
    before { print_item.order_item.update_attribute(:aasm_state, :sublimated) }
    When{ TempShelf.create(print_item_id: print_item.id, serial: 'serial') }
    Then { print_item.reload.qualified? }
  end
end
