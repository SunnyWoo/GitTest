# == Schema Information
#
# Table name: batch_flows
#
#  id                :integer          not null, primary key
#  aasm_state        :string(255)
#  factory_id        :integer
#  product_model_ids :integer          default([]), is an Array
#  print_item_ids    :integer          default([]), is an Array
#  batch_no          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  deadline          :datetime
#  locale            :string(255)
#

FactoryGirl.define do
  factory :batch_flow do
    factory_id { create(:factory).id }
    deadline { Time.zone.now.days_since(12) }
    locale 'zh-TW'
    product_model_ids { [create(:product_model).id] }
  end

  factory :batch_flow_serial_item, class: BatchFlow::FileDumpService::SerialItem do
  end
end
