# == Schema Information
#
# Table name: recommend_sorts
#
#  id              :integer          not null, primary key
#  design_platform :string(255)
#  sort            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

RSpec.describe RecommendSort, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
