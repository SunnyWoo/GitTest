# == Schema Information
#
# Table name: store_components
#
#  id         :integer          not null, primary key
#  store_id   :integer
#  key        :string(255)
#  image      :string(255)
#  position   :integer
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe StoreComponent, type: :model do
  it { should belong_to(:store) }
end
