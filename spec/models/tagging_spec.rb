# == Schema Information
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  taggable_id   :integer
#  tag_id        :integer
#  created_at    :datetime
#  updated_at    :datetime
#  taggable_type :string(255)
#  position      :integer
#

require 'rails_helper'

RSpec.describe Tagging, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
