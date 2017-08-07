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

class TempShelf < ActiveRecord::Base
  strip_attributes only: %i(serial)
  belongs_to :print_item

  validates :serial, presence: true
  after_create :check_print_item

  private

  def check_print_item
    print_item.check!
  end
end
