# == Schema Information
#
# Table name: header_links
#
#  id                    :integer          not null, primary key
#  parent_id             :integer
#  href                  :string(255)
#  link_type             :string(255)
#  spec_id               :integer
#  position              :integer
#  blank                 :boolean          default(FALSE), not null
#  dropdown              :boolean          default(FALSE), not null
#  created_at            :datetime
#  updated_at            :datetime
#  row                   :integer
#  auto_generate_product :boolean          default(FALSE), not null
#

FactoryGirl.define do
  factory :header_link do
    href 'http://localhost:8000/zh-CN/print/print'
    link_type 'create'
    spec_id 1
    position 1
  end
end
