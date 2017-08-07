# == Schema Information
#
# Table name: preview_samples
#
#  id                  :integer          not null, primary key
#  preview_composer_id :integer
#  work_id             :integer
#  result              :string(255)
#  image_meta          :text
#  created_at          :datetime
#  updated_at          :datetime
#

require 'rails_helper'

RSpec.describe PreviewSample, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
