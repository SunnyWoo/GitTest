# == Schema Information
#
# Table name: work_output_files
#
#  id         :integer          not null, primary key
#  work_id    :integer
#  work_type  :string(255)
#  key        :string(255)
#  file       :string(255)
#  image_meta :json
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :work_output_file do
    work
  end
end
