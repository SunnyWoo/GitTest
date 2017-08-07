# == Schema Information
#
# Table name: attachments
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  file_meta  :json
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :attachment do
    process_file_upload true
    file { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
  end
end
