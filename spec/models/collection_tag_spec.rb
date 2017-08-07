# == Schema Information
#
# Table name: collection_tags
#
#  id            :integer          not null, primary key
#  collection_id :integer
#  tag_id        :integer
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

RSpec.describe CollectionTag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
