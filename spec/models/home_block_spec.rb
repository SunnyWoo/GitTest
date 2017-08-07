# == Schema Information
#
# Table name: home_blocks
#
#  id         :integer          not null, primary key
#  template   :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe HomeBlock, type: :model do
  it { should allow_value('collection_2').for(:template) }
  it { should allow_value('collection_3').for(:template) }
  it { should allow_value('collection_4').for(:template) }
end
