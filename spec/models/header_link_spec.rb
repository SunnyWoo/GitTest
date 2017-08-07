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

require 'rails_helper'

RSpec.describe HeaderLink, type: :model do
  it 'FactoryGirl' do
    expect(build(:header_link)).to be_valid
  end
end
