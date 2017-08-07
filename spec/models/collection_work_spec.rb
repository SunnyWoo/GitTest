# == Schema Information
#
# Table name: collection_works
#
#  id            :integer          not null, primary key
#  collection_id :integer
#  work_id       :integer
#  created_at    :datetime
#  updated_at    :datetime
#  work_type     :string(255)
#  position      :integer
#

require 'rails_helper'

RSpec.describe CollectionWork, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
