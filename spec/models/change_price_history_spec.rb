# == Schema Information
#
# Table name: change_price_histories
#
#  id                     :integer          not null, primary key
#  change_price_event_id  :integer
#  changeable_id          :integer
#  changeable_type        :string(255)
#  price_type             :string(255)
#  original_price_tier_id :integer
#  target_price_tier_id   :integer
#  created_at             :datetime
#  updated_at             :datetime
#

require 'rails_helper'

RSpec.describe ChangePriceHistory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
