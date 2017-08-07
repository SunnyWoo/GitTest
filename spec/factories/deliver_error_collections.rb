# == Schema Information
#
# Table name: deliver_error_collections
#
#  id              :integer          not null, primary key
#  order_id        :integer
#  workable_id     :integer
#  workable_type   :string(255)
#  cover_image_url :text
#  print_image_url :text
#  error_messages  :json
#  aasm_state      :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :deliver_error_collection do
    order { create :order }
    workable { create(:work) }
    cover_image_url nil
    print_image_url nil
    error_messages {}
  end
end
