# == Schema Information
#
# Table name: home_block_items
#
#  id         :integer          not null, primary key
#  block_id   :integer
#  image      :string(255)
#  href       :string(255)
#  image_meta :json
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe HomeBlockItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
