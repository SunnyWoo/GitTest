# == Schema Information
#
# Table name: import_orders
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  aasm_state :string(255)
#  failed     :json
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :import_order do
    file { fixture_file_upload('spec/file/import_order_test.csv', 'text/csv') }
  end
end
