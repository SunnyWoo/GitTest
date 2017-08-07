# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  title      :string(255)
#  body       :text
#  mail_to    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  order_no   :string(255)
#

require 'spec_helper'

RSpec.describe Message, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
